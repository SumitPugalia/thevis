defmodule Thevis.Geo.EntityProbe do
  @moduledoc """
  Entity Probe Engine for determining AI recognition of products or companies.

  This module probes AI systems to determine if and how they recognize
  a given product or company entity.
  """

  alias Thevis.AI
  alias Thevis.Accounts.Company
  alias Thevis.Geo.EntityParser
  alias Thevis.Geo.PromptTemplates
  alias Thevis.Products.Product

  @doc """
  Probes an entity (product or company) to see how AI recognizes it.

  ## Parameters
  - `optimizable` - Either a `%Product{}` or `%Company{}` struct
  - `opts` - Options keyword list
    - `:template_type` - Template type to use (default: inferred from entity type)
    - `:adapter_opts` - Options to pass to AI adapter

  ## Returns
  - `{:ok, snapshot_data}` - Success with snapshot data map
  - `{:error, reason}` - Error with reason

  ## Examples

      iex> probe_entity(product, template_type: :product_probe)
      {:ok, %{description: "...", confidence: 0.9, ...}}

  """
  def probe_entity(optimizable, opts \\ [])

  def probe_entity(%Product{} = product, opts) do
    template_type = Keyword.get(opts, :template_type, :product_probe)
    probe_with_prompt(product, template_type, opts)
  end

  def probe_entity(%Company{} = company, opts) do
    template_type = Keyword.get(opts, :template_type, :service_probe)
    probe_with_prompt(company, template_type, opts)
  end

  @doc """
  Probes an entity with a specific prompt template.

  ## Examples

      iex> probe_with_prompt(product, :product_probe)
      {:ok, %{description: "...", confidence: 0.9, ...}}

  """
  def probe_with_prompt(optimizable, template_type, opts \\ [])

  def probe_with_prompt(%Product{} = product, template_type, opts) do
    prompt = PromptTemplates.render_template(template_type, name: product.name)
    adapter_opts = Keyword.get(opts, :adapter_opts, [])

    messages = [
      %{
        role: "user",
        content: prompt
      }
    ]

    case AI.chat_completion(messages, adapter_opts) do
      {:ok, response} ->
        parsed = EntityParser.parse_entity_response(response)
        snapshot_data = build_snapshot_data(product, :product, parsed, template_type, response)
        {:ok, snapshot_data}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def probe_with_prompt(%Company{} = company, template_type, opts) do
    prompt = PromptTemplates.render_template(template_type, name: company.name)
    adapter_opts = Keyword.get(opts, :adapter_opts, [])

    messages = [
      %{
        role: "user",
        content: prompt
      }
    ]

    case AI.chat_completion(messages, adapter_opts) do
      {:ok, response} ->
        parsed = EntityParser.parse_entity_response(response)
        snapshot_data = build_snapshot_data(company, :service, parsed, template_type, response)
        {:ok, snapshot_data}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Analyzes an AI response for a given entity.

  ## Examples

      iex> analyze_response(response, product)
      %{description: "...", confidence: 0.9, ...}

  """
  def analyze_response(response, %Product{} = product) do
    parsed = EntityParser.parse_entity_response(response)
    build_snapshot_data(product, :product, parsed, :product_probe, response)
  end

  def analyze_response(response, %Company{} = company) do
    parsed = EntityParser.parse_entity_response(response)
    build_snapshot_data(company, :service, parsed, :service_probe, response)
  end

  defp build_snapshot_data(entity, optimizable_type, parsed, template_type, response) do
    %{
      optimizable_type: optimizable_type,
      optimizable_id: entity.id,
      ai_description: parsed.description,
      confidence_score: parsed.confidence,
      source_llm: extract_model_name(response),
      prompt_template: Atom.to_string(template_type)
    }
  end

  defp extract_model_name(%{"model" => model}), do: model
  defp extract_model_name(_), do: "unknown"
end

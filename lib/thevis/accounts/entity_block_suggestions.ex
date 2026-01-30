defmodule Thevis.Accounts.EntityBlockSuggestions do
  @moduledoc """
  Suggests entity block fields (one_line_definition, problem_solved, key_concepts)
  for a company using the configured LLM. Used when a client is unsure; admin can
  run this from the company edit form and then edit or submit.
  """

  alias Thevis.AI
  alias Thevis.Accounts.Company

  @doc """
  Asks the LLM to suggest one_line_definition, problem_solved, and key_concepts
  for the given company. Returns string values suitable for form params.

  ## Examples

      iex> suggest_for_company(company)
      {:ok, %{"one_line_definition" => "...", "problem_solved" => "...", "key_concepts" => "..."}}

      iex> suggest_for_company(company)
      {:error, :ai_error}
  """
  @spec suggest_for_company(Company.t()) ::
          {:ok, %{required(String.t()) => String.t()}} | {:error, term()}
  def suggest_for_company(%Company{} = company) do
    prompt = build_prompt(company)
    messages = [%{role: "user", content: prompt}]

    case AI.chat_completion(messages, temperature: 0.3) do
      {:ok, response} ->
        parse_response(response)

      {:error, _reason} ->
        {:error, :ai_error}
    end
  end

  defp build_prompt(company) do
    type_str =
      if company.company_type == :product_based, do: "Product-based", else: "Service-based"

    desc = company.description || "Not provided"

    """
    Given this company, return a JSON object with exactly these three keys (use double quotes for keys and strings):
    - one_line_definition: one sentence describing what the company does, suitable for AI/search and GEO (Generative Engine Optimization). Be specific and include the company name.
    - problem_solved: one sentence stating the main problem the company solves for its customers.
    - key_concepts: a comma-separated list of 3 to 5 key terms or concepts (e.g. "GEO, AI visibility, generative search"). No quotes around the whole value; just the comma-separated list.

    Company name: #{company.name}
    Industry: #{company.industry || "Not provided"}
    Company type: #{type_str}
    Description: #{desc}

    Return only valid JSON, no markdown or code fences. Example format:
    {"one_line_definition": "Acme helps brands...", "problem_solved": "Brands struggle with...", "key_concepts": "GEO, AI visibility, search"}
    """
  end

  defp parse_response(%{"choices" => [%{"message" => %{"content" => content}} | _]})
       when is_binary(content) do
    content
    |> String.trim()
    |> strip_code_fence()
    |> Jason.decode()
    |> case do
      {:ok, %{} = map} ->
        result = %{
          "one_line_definition" => get_string(map, "one_line_definition"),
          "problem_solved" => get_string(map, "problem_solved"),
          "key_concepts" => get_string(map, "key_concepts")
        }

        {:ok, result}

      {:ok, _} ->
        {:error, :invalid_format}

      {:error, _} ->
        {:error, :invalid_json}
    end
  end

  defp parse_response(_), do: {:error, :invalid_response}

  defp strip_code_fence(str) do
    str
    |> String.replace(~r/^```(?:json)?\s*/i, "")
    |> String.replace(~r/\s*```\s*$/i, "")
    |> String.trim()
  end

  defp get_string(map, key) do
    case map do
      %{^key => v} when is_binary(v) -> v
      %{^key => v} when not is_nil(v) -> to_string(v)
      _ -> ""
    end
  end
end

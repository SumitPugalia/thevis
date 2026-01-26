defmodule Thevis.AI.OpenAIAdapter do
  @moduledoc """
  OpenAI API adapter implementation.

  This adapter implements the Thevis.AI.Adapter behaviour for OpenAI's API.
  """

  @behaviour Thevis.AI.Adapter

  defstruct [:api_key, :base_url, :model, :embedding_model]

  @default_base_url "https://api.openai.com/v1"
  @default_model "gpt-4o-mini"
  @default_embedding_model "text-embedding-3-small"

  @doc """
  Creates a new OpenAI adapter instance.

  ## Options
  - `:api_key` - OpenAI API key (required)
  - `:base_url` - API base URL (default: "https://api.openai.com/v1")
  - `:model` - Chat model to use (default: "gpt-4o-mini")
  - `:embedding_model` - Embedding model to use (default: "text-embedding-3-small")

  ## Examples

      adapter = Thevis.AI.OpenAIAdapter.new(api_key: "sk-...")

  """
  def new(opts \\ []) do
    api_key = Keyword.get(opts, :api_key) || System.get_env("OPENAI_API_KEY")

    if is_nil(api_key) do
      raise ArgumentError,
            "OpenAI API key is required. Set OPENAI_API_KEY environment variable or pass :api_key option."
    end

    %__MODULE__{
      api_key: api_key,
      base_url: Keyword.get(opts, :base_url, @default_base_url),
      model: Keyword.get(opts, :model, @default_model),
      embedding_model: Keyword.get(opts, :embedding_model, @default_embedding_model)
    }
  end

  @impl Thevis.AI.Adapter
  def chat_completion(messages, opts \\ []) do
    adapter_opts = Keyword.take(opts, [:api_key, :base_url, :model, :embedding_model])
    adapter = new(adapter_opts)
    request_opts = Keyword.drop(opts, [:api_key, :base_url, :model, :embedding_model])
    do_chat_completion(adapter, messages, request_opts)
  end

  @impl Thevis.AI.Adapter
  def embed_text(text) do
    adapter = new()
    do_embed_text(adapter, text)
  end

  defp do_chat_completion(adapter, messages, opts) do
    url = "#{adapter.base_url}/chat/completions"

    body =
      %{
        model: Keyword.get(opts, :model, adapter.model),
        messages: messages,
        temperature: Keyword.get(opts, :temperature, 0.7),
        max_tokens: Keyword.get(opts, :max_tokens)
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    headers = [
      {"Authorization", "Bearer #{adapter.api_key}"},
      {"Content-Type", "application/json"}
    ]

    case Req.post(url, json: body, headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_embed_text(adapter, text) do
    url = "#{adapter.base_url}/embeddings"

    body = %{
      model: adapter.embedding_model,
      input: text
    }

    headers = [
      {"Authorization", "Bearer #{adapter.api_key}"},
      {"Content-Type", "application/json"}
    ]

    case Req.post(url, json: body, headers: headers) do
      {:ok, %{status: 200, body: %{"data" => [%{"embedding" => embedding} | _]}}} ->
        {:ok, embedding}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

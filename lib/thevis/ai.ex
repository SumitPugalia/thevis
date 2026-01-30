defmodule Thevis.AI do
  @moduledoc """
  AI adapter management and configuration.

  This module provides a unified interface to access the configured AI adapter.
  """

  @cache_key :thevis_ai_cached_adapter

  @doc """
  Gets the configured AI adapter, cached per process to avoid repeated config lookups and adapter creation.

  ## Examples

      iex> adapter = Thevis.AI.get_adapter()
      %Thevis.AI.OpenAIAdapter{}

  """
  def get_adapter do
    case Process.get(@cache_key) do
      nil ->
        adapter = build_adapter()
        Process.put(@cache_key, adapter)
        adapter

      cached ->
        cached
    end
  end

  defp build_adapter do
    config = Application.get_env(:thevis, Thevis.AI, [])
    adapter_module = Keyword.get(config, :adapter, Thevis.AI.OpenAIAdapter)

    if Code.ensure_loaded?(adapter_module) && function_exported?(adapter_module, :new, 1) do
      adapter_config = Keyword.take(config, [:api_key, :base_url, :model, :embedding_model])
      adapter_module.new(adapter_config)
    else
      adapter_module
    end
  end

  @doc """
  Sends a chat completion request using the configured adapter.

  ## Examples

      Thevis.AI.chat_completion([
        %{role: "user", content: "Hello"}
      ])

  """
  def chat_completion(messages, opts \\ []) do
    adapter = get_adapter()
    adapter.chat_completion(messages, opts)
  end

  @doc """
  Generates embeddings using the configured adapter.

  ## Examples

      Thevis.AI.embed_text("Some text")

  """
  def embed_text(text) do
    adapter = get_adapter()
    adapter.embed_text(text)
  end
end

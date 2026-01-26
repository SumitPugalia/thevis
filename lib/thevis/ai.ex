defmodule Thevis.AI do
  @moduledoc """
  AI adapter management and configuration.

  This module provides a unified interface to access the configured AI adapter.
  """

  @doc """
  Gets the configured AI adapter.

  ## Examples

      iex> adapter = Thevis.AI.get_adapter()
      %Thevis.AI.OpenAIAdapter{}

  """
  def get_adapter do
    config = Application.get_env(:thevis, Thevis.AI, [])
    adapter_module = Keyword.get(config, :adapter, Thevis.AI.OpenAIAdapter)

    # For mock adapters (Mox), just return the module
    # Mox mocks don't have a new/1 function, check if it exists
    if Code.ensure_loaded?(adapter_module) && function_exported?(adapter_module, :new, 1) do
      # Extract adapter-specific config
      adapter_config = Keyword.take(config, [:api_key, :base_url, :model, :embedding_model])
      adapter_module.new(adapter_config)
    else
      # Mock adapter (no new/1 function) - return module directly
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

defmodule Thevis.AI.Adapter do
  @moduledoc """
  Behaviour for AI/LLM adapters.

  This behaviour defines the interface that all AI adapters must implement.
  It allows the system to work with multiple LLM providers (OpenAI, Anthropic, etc.)
  through a consistent interface.
  """

  @doc """
  Sends a chat completion request to the AI provider.

  ## Parameters
  - `messages`: List of message maps with `role` and `content` keys
  - `opts`: Keyword list of options (temperature, max_tokens, etc.)

  ## Returns
  - `{:ok, response}` - Success with response map
  - `{:error, reason}` - Error with reason

  ## Examples

      adapter.chat_completion([
        %{role: "system", content: "You are a helpful assistant"},
        %{role: "user", content: "What is AI?"}
      ], temperature: 0.7)

  """
  @callback chat_completion(messages :: list(map()), opts :: keyword()) ::
              {:ok, response :: map()} | {:error, reason :: term()}

  @doc """
  Generates embeddings for text.

  ## Parameters
  - `text`: String to embed

  ## Returns
  - `{:ok, embedding}` - Success with list of floats (embedding vector)
  - `{:error, reason}` - Error with reason

  ## Examples

      adapter.embed_text("This is some text to embed")

  """
  @callback embed_text(text :: String.t()) ::
              {:ok, embedding :: list(float())} | {:error, reason :: term()}
end

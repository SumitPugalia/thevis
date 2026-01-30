defmodule Thevis.Geo.Vectorizer do
  @moduledoc """
  Vectorizer module for converting text to embeddings using AI.
  """

  alias Thevis.AI

  @doc """
  Vectorizes text content into an embedding vector.
  """
  def vectorize_text(text) when is_binary(text) do
    case AI.embed_text(text) do
      {:ok, embedding} when is_list(embedding) ->
        # Return list - pgvector will handle conversion in changeset
        {:ok, embedding}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def vectorize_text(_), do: {:error, :invalid_text}

  @doc """
  Vectorizes multiple text chunks in batch.
  """
  def vectorize_batch(texts) when is_list(texts) do
    results =
      Enum.map(texts, fn text ->
        case vectorize_text(text) do
          {:ok, embedding} -> {:ok, embedding}
          {:error, reason} -> {:error, reason}
        end
      end)

    {:ok, results}
  end

  def vectorize_batch(_), do: {:error, :invalid_input}
end

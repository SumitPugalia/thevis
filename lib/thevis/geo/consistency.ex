defmodule Thevis.Geo.Consistency do
  @moduledoc """
  Consistency Engine for detecting messaging variance across sources.
  """

  alias Thevis.Accounts.Company
  alias Thevis.Geo.DriftScore
  alias Thevis.Geo.Embedding
  alias Thevis.Geo.Vectorizer
  alias Thevis.Products.Product
  alias Thevis.Repo
  import Ecto.Query

  @doc """
  Analyzes consistency for a given optimizable entity.
  """
  def analyze_consistency(optimizable, sources) when is_list(sources) do
    # Get reference description (from entity snapshot or product/company description)
    reference_description = get_reference_description(optimizable)

    if is_nil(reference_description) do
      {:error, :no_reference_description}
    else
      analyze_with_reference(optimizable, sources, reference_description)
    end
  end

  defp analyze_with_reference(optimizable, sources, reference_description) do
    case Vectorizer.vectorize_text(reference_description) do
      {:ok, reference_embedding} ->
        drift_scores =
          Enum.map(sources, fn source ->
            calculate_drift_for_source(
              optimizable,
              source,
              reference_description,
              reference_embedding
            )
          end)

        {:ok, drift_scores}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Calculates drift score between source description and reference.
  """
  def calculate_drift_score(source_description, reference_description) do
    case {Vectorizer.vectorize_text(source_description),
          Vectorizer.vectorize_text(reference_description)} do
      {{:ok, source_embedding}, {:ok, reference_embedding}} ->
        similarity = cosine_similarity(source_embedding, reference_embedding)
        # Drift score is inverse of similarity (1 - similarity)
        drift_score = 1.0 - similarity
        {:ok, drift_score, similarity}

      {{:error, reason}, _} ->
        {:error, reason}

      {_, {:error, reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Detects variance between AI description and actual sources.
  """
  def detect_variance(optimizable, ai_description) do
    # Get all embeddings for this optimizable
    embeddings = get_embeddings_for_optimizable(optimizable)

    if embeddings == [] do
      {:ok, []}
    else
      detect_variance_with_embeddings(optimizable, ai_description, embeddings)
    end
  end

  defp detect_variance_with_embeddings(_optimizable, ai_description, embeddings) do
    case Vectorizer.vectorize_text(ai_description) do
      {:ok, ai_embedding} ->
        variances = calculate_variances(embeddings, ai_embedding)
        {:ok, variances}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp calculate_variances(embeddings, ai_embedding) do
    Enum.map(embeddings, fn embedding ->
      similarity = cosine_similarity(ai_embedding, embedding.embedding)
      drift = 1.0 - similarity

      %{
        source_type: embedding.source_type,
        source_url: embedding.source_url,
        drift_score: drift,
        similarity_score: similarity
      }
    end)
  end

  @doc """
  Stores drift scores in the database.
  """
  def store_drift_scores(optimizable, drift_scores) do
    optimizable_type = get_optimizable_type(optimizable)
    optimizable_id = optimizable.id

    Enum.each(drift_scores, fn drift_data ->
      attrs = %{
        optimizable_type: optimizable_type,
        optimizable_id: optimizable_id,
        drift_score: drift_data[:drift_score] || drift_data.drift_score,
        source_type: to_string(drift_data[:source_type] || drift_data.source_type),
        source_description: drift_data[:source_description],
        reference_description: drift_data[:reference_description],
        similarity_score: drift_data[:similarity_score] || drift_data.similarity_score,
        metadata: drift_data[:metadata] || %{}
      }

      %DriftScore{}
      |> DriftScore.changeset(attrs)
      |> Repo.insert()
    end)
  end

  defp calculate_drift_for_source(optimizable, source, reference_description, reference_embedding) do
    source_description = extract_description_from_source(source)

    case Vectorizer.vectorize_text(source_description) do
      {:ok, source_embedding} ->
        similarity = cosine_similarity(source_embedding, reference_embedding)
        drift_score = 1.0 - similarity

        %{
          optimizable: optimizable,
          source_type: source[:source_type] || source.source_type,
          source_description: source_description,
          reference_description: reference_description,
          drift_score: drift_score,
          similarity_score: similarity
        }

      {:error, _reason} ->
        %{
          optimizable: optimizable,
          source_type: source[:source_type] || source.source_type,
          source_description: source_description,
          reference_description: reference_description,
          drift_score: 1.0,
          similarity_score: 0.0
        }
    end
  end

  defp extract_description_from_source(source) do
    source[:content] || source[:description] || source[:source_content] || ""
  end

  defp get_reference_description(%Product{} = product) do
    product.description || product.name
  end

  defp get_reference_description(%Company{} = company) do
    company.description || company.name
  end

  defp get_embeddings_for_optimizable(optimizable) do
    optimizable_type = get_optimizable_type(optimizable)

    query =
      from(e in Embedding,
        where: e.optimizable_type == ^optimizable_type,
        where: e.optimizable_id == ^optimizable.id
      )

    Repo.all(query)
  end

  defp get_optimizable_type(%Product{}), do: :product
  defp get_optimizable_type(%Company{}), do: :service

  defp cosine_similarity(_embedding1, _embedding2) do
    # Calculate cosine similarity between two vectors
    # This is a simplified version - in production, use proper vector math
    # For now, return a mock similarity score
    # TODO: Implement proper cosine similarity calculation using pgvector
    # Can use: SELECT embedding1 <=> embedding2 FROM embeddings;
    0.85
  end
end

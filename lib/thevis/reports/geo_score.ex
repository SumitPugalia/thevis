defmodule Thevis.Reports.GeoScore do
  @moduledoc """
  GEO Score calculation module.

  GEO Score is a composite metric (0-100) that combines:
  - Recognition confidence (0-40 points)
  - Recall percentage (0-40 points)
  - First mention rank (0-20 points)

  Higher scores indicate better AI visibility.
  """

  @doc """
  Calculates GEO Score from entity snapshot and recall results.

  ## Parameters
  - `entity_snapshot`: The EntitySnapshot struct (can be nil)
  - `recall_results`: List of RecallResult structs

  ## Returns
  A float between 0 and 100 representing the GEO Score.

  ## Examples

      iex> snapshot = %EntitySnapshot{recognized: true, recognition_confidence: 0.85}
      iex> recall_results = [%RecallResult{mentioned: true}, %RecallResult{mentioned: false}]
      iex> calculate_geo_score(snapshot, recall_results)
      65.0

  """
  @spec calculate_geo_score(
          Thevis.Geo.EntitySnapshot.t() | nil,
          [Thevis.Geo.RecallResult.t()]
        ) :: float()
  def calculate_geo_score(nil, _recall_results), do: 0.0

  def calculate_geo_score(entity_snapshot, recall_results) when is_list(recall_results) do
    recognition_score = calculate_recognition_score(entity_snapshot)
    recall_score = calculate_recall_score(recall_results)
    mention_rank_score = calculate_mention_rank_score(recall_results)

    recognition_score + recall_score + mention_rank_score
  end

  def calculate_geo_score(_entity_snapshot, _recall_results), do: 0.0

  # Recognition score: 0-40 points based on confidence score
  defp calculate_recognition_score(%{confidence_score: confidence})
       when is_float(confidence) do
    confidence * 40.0
  end

  defp calculate_recognition_score(_), do: 0.0

  # Recall score: 0-40 points based on recall percentage
  defp calculate_recall_score(recall_results) when is_list(recall_results) do
    recall_percentage = Thevis.Geo.RecallScorer.calculate_recall_percentage(recall_results)
    recall_percentage * 0.4
  end

  defp calculate_recall_score(_), do: 0.0

  # Mention rank score: 0-20 points (lower rank = higher score)
  defp calculate_mention_rank_score(recall_results) when is_list(recall_results) do
    avg_rank = Thevis.Geo.RecallScorer.calculate_first_mention_rank(recall_results)

    case avg_rank do
      nil -> 0.0
      rank when rank <= 1 -> 20.0
      rank when rank <= 2 -> 15.0
      rank when rank <= 3 -> 10.0
      rank when rank <= 5 -> 5.0
      _ -> 0.0
    end
  end

  defp calculate_mention_rank_score(_), do: 0.0
end

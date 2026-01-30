defmodule Thevis.Strategy.OpportunityDetector do
  @moduledoc """
  Opportunity Detector module for identifying optimization opportunities from scan results.
  """

  alias Thevis.Geo
  alias Thevis.Projects.Project
  alias Thevis.Scans

  @doc """
  Detects opportunities for a project based on scan results.
  """
  def detect_opportunities(%Project{} = project) do
    # Get latest scan results
    latest_scan_run = get_latest_scan_run(project)

    if latest_scan_run do
      opportunities =
        [
          detect_recall_opportunities(project, latest_scan_run),
          detect_authority_opportunities(project, latest_scan_run),
          detect_consistency_opportunities(project, latest_scan_run),
          detect_confidence_opportunities(project, latest_scan_run)
        ]
        |> List.flatten()
        |> rank_opportunities()

      {:ok, opportunities}
    else
      {:ok, []}
    end
  end

  @doc """
  Ranks opportunities by impact and priority.
  """
  def rank_opportunities(opportunities) do
    opportunities
    |> Enum.map(&calculate_impact_score/1)
    |> Enum.sort_by(& &1.impact_score, :desc)
  end

  @doc """
  Categorizes opportunities by type.
  """
  def categorize_opportunities(opportunities) do
    Enum.group_by(opportunities, & &1.category)
  end

  defp get_latest_scan_run(project) do
    Scans.list_scan_runs(project)
    |> Enum.sort_by(& &1.inserted_at, :desc)
    |> List.first()
  end

  defp detect_recall_opportunities(_project, scan_run) do
    recall_results = Geo.list_recall_results(scan_run)

    if recall_results != [] do
      mention_rate = calculate_mention_rate(recall_results)

      if mention_rate < 0.5 do
        [
          %{
            category: :recall,
            title: "Low Recall Rate",
            description:
              "Product is mentioned in only #{Integer.to_string(round(mention_rate * 100))}% of test prompts",
            impact_score: calculate_recall_impact(mention_rate),
            priority: :high,
            recommendations: ["Improve product visibility", "Enhance SEO", "Create content"]
          }
        ]
      else
        []
      end
    else
      []
    end
  end

  defp detect_authority_opportunities(_project, _scan_run) do
    # Check authority scores if available
    # For now, return empty list - will be enhanced when authority scans are run
    []
  end

  defp detect_consistency_opportunities(_project, _scan_run) do
    # Check drift scores if available
    # For now, return empty list - will be enhanced when consistency scans are run
    []
  end

  defp detect_confidence_opportunities(_project, scan_run) do
    snapshots = Geo.list_entity_snapshots(scan_run)

    if snapshots != [] do
      scores =
        snapshots
        |> Enum.map(& &1.confidence_score)
        |> Enum.filter(& &1)

      avg_confidence =
        if scores == [] do
          0.0
        else
          sum = Enum.sum(scores)
          count = length(scores)
          sum / count
        end

      if avg_confidence < 0.7 do
        [
          %{
            category: :confidence,
            title: "Low AI Confidence",
            description: "Average confidence score is #{round(avg_confidence * 100)}%",
            impact_score: calculate_confidence_impact(avg_confidence),
            priority: :high,
            recommendations: ["Improve product description", "Enhance messaging clarity"]
          }
        ]
      else
        []
      end
    else
      []
    end
  end

  defp calculate_mention_rate(recall_results) do
    total = length(recall_results)
    mentioned = Enum.count(recall_results, & &1.mentioned)

    if total > 0 do
      mentioned / total
    else
      0.0
    end
  end

  defp calculate_recall_impact(mention_rate) do
    # Lower mention rate = higher impact
    (1.0 - mention_rate) * 100
  end

  defp calculate_confidence_impact(confidence) do
    # Lower confidence = higher impact
    (1.0 - confidence) * 100
  end

  defp calculate_impact_score(opportunity) do
    base_score = opportunity.impact_score || 50.0

    priority_multiplier =
      case opportunity.priority do
        :critical -> 1.5
        :high -> 1.2
        :medium -> 1.0
        :low -> 0.8
      end

    Map.put(opportunity, :impact_score, base_score * priority_multiplier)
  end
end

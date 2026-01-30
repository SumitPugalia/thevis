defmodule Thevis.Automation.PerformanceTracker do
  @moduledoc """
  Performance tracking module for content items and campaigns.
  """

  alias Thevis.Automation

  @doc """
  Tracks performance metrics for a content item.
  """
  def track_content_performance(%Automation.ContentItem{} = content_item, metrics) do
    current_metrics = content_item.performance_metrics || %{}

    updated_metrics =
      current_metrics
      |> Map.merge(metrics)
      |> Map.put(:last_updated, DateTime.utc_now() |> DateTime.to_iso8601())

    Automation.update_content_item(content_item, %{performance_metrics: updated_metrics})
  end

  @doc """
  Calculates performance score for a content item.
  """
  def calculate_performance_score(%Automation.ContentItem{} = content_item) do
    metrics = content_item.performance_metrics || %{}

    views = Map.get(metrics, "views", 0) || 0
    clicks = Map.get(metrics, "clicks", 0) || 0
    shares = Map.get(metrics, "shares", 0) || 0
    engagement = Map.get(metrics, "engagement", 0.0) || 0.0

    # Simple scoring algorithm
    view_score = min(views / 1000.0, 1.0) * 30.0
    click_score = if views > 0, do: clicks / views * 40.0, else: 0.0
    share_score = min(shares / 100.0, 1.0) * 20.0
    engagement_score = engagement * 10.0

    total_score = view_score + click_score + share_score + engagement_score
    min(total_score, 100.0)
  end

  @doc """
  Gets performance summary for a campaign.
  """
  def get_campaign_performance_summary(campaign_id) do
    content_items = Automation.list_content_items(campaign_id)

    if content_items != [] do
      total_items = length(content_items)
      published_items = Enum.count(content_items, fn item -> item.status == :published end)

      total_views =
        Enum.reduce(content_items, 0, fn item, acc ->
          views = get_metric_value(item, "views")
          acc + views
        end)

      total_clicks =
        Enum.reduce(content_items, 0, fn item, acc ->
          clicks = get_metric_value(item, "clicks")
          acc + clicks
        end)

      total_shares =
        Enum.reduce(content_items, 0, fn item, acc ->
          shares = get_metric_value(item, "shares")
          acc + shares
        end)

      avg_performance_score =
        content_items
        |> Enum.map(&calculate_performance_score/1)
        |> Enum.filter(&(&1 > 0))
        |> case do
          [] -> 0.0
          scores -> Enum.sum(scores) / length(scores)
        end

      %{
        campaign_id: campaign_id,
        total_content_items: total_items,
        published_items: published_items,
        total_views: total_views,
        total_clicks: total_clicks,
        total_shares: total_shares,
        average_performance_score: avg_performance_score,
        published_rate: if(total_items > 0, do: published_items / total_items * 100.0, else: 0.0)
      }
    else
      %{
        campaign_id: campaign_id,
        total_content_items: 0,
        published_items: 0,
        total_views: 0,
        total_clicks: 0,
        total_shares: 0,
        average_performance_score: 0.0,
        published_rate: 0.0
      }
    end
  end

  @doc """
  Updates performance metrics from external sources (e.g., analytics APIs).
  """
  def update_metrics_from_external(content_item_id, external_metrics) do
    content_item = Automation.get_content_item!(content_item_id)

    normalized_metrics = normalize_external_metrics(external_metrics)

    track_content_performance(content_item, normalized_metrics)
  end

  defp get_metric_value(content_item, key) do
    metrics = content_item.performance_metrics || %{}
    Map.get(metrics, key, 0) || Map.get(metrics, String.to_atom(key), 0) || 0
  end

  defp normalize_external_metrics(metrics) when is_map(metrics) do
    %{
      "views" => Map.get(metrics, "views") || Map.get(metrics, :views) || 0,
      "clicks" => Map.get(metrics, "clicks") || Map.get(metrics, :clicks) || 0,
      "shares" => Map.get(metrics, "shares") || Map.get(metrics, :shares) || 0,
      "engagement" => Map.get(metrics, "engagement") || Map.get(metrics, :engagement) || 0.0
    }
  end

  defp normalize_external_metrics(_), do: %{}
end

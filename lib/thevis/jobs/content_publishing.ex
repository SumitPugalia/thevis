defmodule Thevis.Jobs.ContentPublishing do
  @moduledoc """
  Background job for publishing content items to platforms.
  """

  use Oban.Worker, queue: :reports, max_attempts: 3

  alias Thevis.Automation
  alias Thevis.Automation.ContentWikiSync
  alias Thevis.Automation.PerformanceTracker
  alias Thevis.Geo.Automation.Publisher

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"content_item_id" => content_item_id}}) do
    content_item = Automation.get_content_item!(content_item_id)

    case Publisher.publish_content_item(content_item) do
      {:ok, updated_item} ->
        # Auto-sync to wiki if applicable
        sync_to_wiki_if_needed(updated_item)

        # Initialize performance tracking
        PerformanceTracker.track_content_performance(updated_item, %{
          "views" => 0,
          "clicks" => 0,
          "shares" => 0,
          "engagement" => 0.0
        })

        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp sync_to_wiki_if_needed(%Automation.ContentItem{} = content_item) do
    if content_item.status == :published do
      ContentWikiSync.auto_sync_on_publish(content_item)
    end
  end
end

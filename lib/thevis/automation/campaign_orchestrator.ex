defmodule Thevis.Automation.CampaignOrchestrator do
  @moduledoc """
  Campaign Orchestrator for coordinating campaign execution, content generation, and publishing.
  """

  alias Thevis.Automation
  alias Thevis.Jobs.CampaignExecution
  alias Thevis.Jobs.ContentGeneration
  alias Thevis.Jobs.ContentPublishing

  @doc """
  Starts a campaign and schedules its execution.
  """
  def start_campaign(campaign) do
    case Automation.start_campaign(campaign) do
      {:ok, updated_campaign} ->
        schedule_campaign_execution(updated_campaign)
        {:ok, updated_campaign}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Schedules campaign execution as a background job.
  """
  def schedule_campaign_execution(campaign) do
    %{"campaign_id" => campaign.id}
    |> CampaignExecution.new()
    |> Oban.insert()
  end

  @doc """
  Schedules content generation for a campaign.
  """
  def schedule_content_generation(campaign, content_types) do
    Enum.each(content_types, fn content_type ->
      %{
        "project_id" => campaign.project_id,
        "content_type" => Atom.to_string(content_type),
        "campaign_id" => campaign.id
      }
      |> ContentGeneration.new()
      |> Oban.insert()
    end)
  end

  @doc """
  Schedules content publishing for a content item.
  """
  def schedule_content_publishing(content_item) do
    %{"content_item_id" => content_item.id}
    |> ContentPublishing.new()
    |> Oban.insert()
  end

  @doc """
  Executes a full campaign workflow: generation -> optimization -> publishing.
  """
  def execute_campaign_workflow(campaign) do
    # Step 1: Generate content
    content_types = get_content_types_for_campaign(campaign.campaign_type)

    Enum.each(content_types, fn content_type ->
      schedule_content_generation(campaign, [content_type])
    end)

    # Step 2: Schedule publishing for generated content
    # Note: In a real implementation, we'd wait for generation to complete
    # For now, this is a simplified workflow
    :ok
  end

  defp get_content_types_for_campaign(:content) do
    [:blog_post, :github_readme, :wiki_page]
  end

  defp get_content_types_for_campaign(:authority) do
    [:wiki_page, :documentation]
  end

  defp get_content_types_for_campaign(:consistency) do
    [:wiki_page]
  end

  defp get_content_types_for_campaign(:full) do
    [:blog_post, :github_readme, :documentation, :wiki_page, :article]
  end

  defp get_content_types_for_campaign(:product_launch) do
    [:wiki_page, :blog_post, :github_readme]
  end
end

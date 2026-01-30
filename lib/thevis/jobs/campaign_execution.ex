defmodule Thevis.Jobs.CampaignExecution do
  @moduledoc """
  Background job for executing automation campaigns.
  """

  use Oban.Worker, queue: :reports, max_attempts: 3

  alias Thevis.Automation
  alias Thevis.Automation.ContentHelpers
  alias Thevis.Geo.Automation.ContentCreator

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"campaign_id" => campaign_id}}) do
    campaign = Automation.get_campaign!(campaign_id)

    if campaign.status == :active do
      execute_campaign(campaign)
    else
      {:error, :campaign_not_active}
    end
  end

  defp execute_campaign(campaign) do
    # Generate content based on campaign type
    content_types = get_content_types_for_campaign(campaign.campaign_type)

    results =
      Enum.map(content_types, fn content_type ->
        generate_and_store_content(campaign, content_type)
      end)

    # Track results
    Enum.each(results, fn result ->
      case result do
        {:ok, content_item} ->
          create_automation_result(campaign, :content_created, content_item)

        {:error, _reason} ->
          create_automation_result(campaign, :content_created, %{error: "failed"})
      end
    end)

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

  defp generate_and_store_content(campaign, content_type) do
    campaign_with_project = Thevis.Repo.preload(campaign, :project)
    project = campaign_with_project.project

    case ContentCreator.generate_content(project, content_type) do
      {:ok, content} ->
        platform = ContentHelpers.get_platform_for_content_type(content_type)

        attrs = %{
          campaign_id: campaign.id,
          project_id: project.id,
          content_type: content_type,
          title: ContentHelpers.generate_title(project, content_type),
          content: content,
          platform: platform,
          status: :draft
        }

        Automation.create_content_item(attrs)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_automation_result(campaign, action_type, details) do
    details_map =
      if is_map(details) do
        details
      else
        %{item: inspect(details)}
      end

    attrs = %{
      campaign_id: campaign.id,
      action_type: action_type,
      action_details: details_map,
      status: :executed,
      executed_at: DateTime.utc_now()
    }

    Automation.create_automation_result(attrs)
  end
end

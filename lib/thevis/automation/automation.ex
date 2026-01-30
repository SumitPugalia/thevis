defmodule Thevis.Automation do
  @moduledoc """
  The Automation context for managing campaigns, content items, and automation results.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Automation.AutomationResult
  alias Thevis.Automation.Campaign
  alias Thevis.Automation.ContentItem

  ## Campaigns

  @doc """
  Returns the list of campaigns for a project.
  """
  def list_campaigns(project_id, filters \\ %{}) do
    base_query =
      from(c in Campaign, where: c.project_id == ^project_id)
      |> preload([:project])

    base_query
    |> apply_campaign_filters(filters)
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single campaign.
  """
  def get_campaign!(id), do: Repo.get!(Campaign, id)

  @doc """
  Creates a campaign.
  """
  def create_campaign(attrs \\ %{}) do
    %Campaign{}
    |> Campaign.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a campaign.
  """
  def update_campaign(%Campaign{} = campaign, attrs) do
    campaign
    |> Campaign.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a campaign.
  """
  def delete_campaign(%Campaign{} = campaign) do
    Repo.delete(campaign)
  end

  @doc """
  Starts a campaign.
  """
  def start_campaign(%Campaign{} = campaign) do
    update_campaign(campaign, %{
      status: :active,
      started_at: DateTime.utc_now()
    })
  end

  @doc """
  Completes a campaign.
  """
  def complete_campaign(%Campaign{} = campaign) do
    update_campaign(campaign, %{
      status: :completed,
      completed_at: DateTime.utc_now()
    })
  end

  ## Content Items

  @doc """
  Returns the list of content items for a campaign.
  """
  def list_content_items(campaign_id, filters \\ %{}) do
    base_query = from(ci in ContentItem, where: ci.campaign_id == ^campaign_id)

    base_query
    |> apply_content_filters(filters)
    |> order_by([ci], desc: ci.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single content item.
  """
  def get_content_item!(id), do: Repo.get!(ContentItem, id)

  @doc """
  Creates a content item.
  """
  def create_content_item(attrs \\ %{}) do
    %ContentItem{}
    |> ContentItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a content item.
  """
  def update_content_item(%ContentItem{} = content_item, attrs) do
    content_item
    |> ContentItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a content item.
  """
  def delete_content_item(%ContentItem{} = content_item) do
    Repo.delete(content_item)
  end

  ## Automation Results

  @doc """
  Returns the list of automation results for a campaign.
  """
  def list_automation_results(campaign_id, filters \\ %{}) do
    base_query = from(ar in AutomationResult, where: ar.campaign_id == ^campaign_id)

    base_query
    |> apply_result_filters(filters)
    |> order_by([ar], desc: ar.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single automation result.
  """
  def get_automation_result!(id), do: Repo.get!(AutomationResult, id)

  @doc """
  Creates an automation result.
  """
  def create_automation_result(attrs \\ %{}) do
    %AutomationResult{}
    |> AutomationResult.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an automation result.
  """
  def update_automation_result(%AutomationResult{} = automation_result, attrs) do
    automation_result
    |> AutomationResult.changeset(attrs)
    |> Repo.update()
  end

  defp apply_campaign_filters(query, %{status: status}) do
    where(query, [c], c.status == ^status)
  end

  defp apply_campaign_filters(query, %{campaign_type: campaign_type}) do
    where(query, [c], c.campaign_type == ^campaign_type)
  end

  defp apply_campaign_filters(query, _), do: query

  defp apply_content_filters(query, %{content_type: content_type}) do
    where(query, [ci], ci.content_type == ^content_type)
  end

  defp apply_content_filters(query, %{platform: platform}) do
    where(query, [ci], ci.platform == ^platform)
  end

  defp apply_content_filters(query, %{status: status}) do
    where(query, [ci], ci.status == ^status)
  end

  defp apply_content_filters(query, _), do: query

  defp apply_result_filters(query, %{action_type: action_type}) do
    where(query, [ar], ar.action_type == ^action_type)
  end

  defp apply_result_filters(query, %{status: status}) do
    where(query, [ar], ar.status == ^status)
  end

  defp apply_result_filters(query, _), do: query
end

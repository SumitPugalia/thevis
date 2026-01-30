defmodule Thevis.Automation.ContentWikiSync do
  @moduledoc """
  Integration module for syncing content items to wiki pages.
  """

  alias Thevis.Automation
  alias Thevis.Projects
  alias Thevis.Wikis

  @doc """
  Syncs a content item to a wiki page.
  """
  def sync_content_to_wiki(
        %Automation.ContentItem{} = content_item,
        platform_name \\ "Company Wiki"
      ) do
    project = Projects.get_project(content_item.project_id)

    if project do
      case Wikis.get_wiki_platform_by_name(platform_name) do
        nil ->
          {:error, :platform_not_found}

        platform ->
          create_or_update_wiki_page(project, platform, content_item)
      end
    else
      {:error, :project_not_found}
    end
  end

  @doc """
  Syncs all published content items for a campaign to wikis.
  """
  def sync_campaign_content_to_wikis(campaign_id, platform_name \\ "Company Wiki") do
    _campaign = Automation.get_campaign!(campaign_id)

    content_items =
      Automation.list_content_items(campaign_id, %{status: :published})
      |> Enum.filter(fn item -> item.status == :published end)

    results =
      Enum.map(content_items, fn content_item ->
        sync_content_to_wiki(content_item, platform_name)
      end)

    successful = Enum.count(results, fn result -> match?({:ok, _}, result) end)
    failed = length(results) - successful

    {:ok, %{successful: successful, failed: failed, results: results}}
  end

  @doc """
  Auto-syncs content items to wikis when they are published.
  """
  def auto_sync_on_publish(%Automation.ContentItem{} = content_item) do
    if content_item.status == :published do
      # Determine platform based on content type
      platform = determine_platform_for_content(content_item.content_type)

      sync_content_to_wiki(content_item, platform)
    else
      {:ok, :not_published}
    end
  end

  defp create_or_update_wiki_page(project, platform, content_item) do
    page_title = content_item.title || "Untitled Page"
    page_content = content_item.content || ""

    # Check if wiki page already exists
    existing_page = Wikis.get_wiki_page_by_title(project.id, page_title)

    if existing_page do
      # Update existing page
      update_wiki_page_content(existing_page, page_content, content_item)
    else
      # Create new page
      create_wiki_page(project, platform, page_title, page_content, content_item)
    end
  end

  defp create_wiki_page(project, platform, title, content, content_item) do
    attrs = %{
      project_id: project.id,
      platform_id: platform.id,
      title: title,
      status: :draft,
      metadata: %{
        content_item_id: content_item.id,
        campaign_id: content_item.campaign_id,
        synced_at: DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    case Wikis.create_wiki_page(attrs) do
      {:ok, wiki_page} ->
        # Create initial content version
        content_attrs = %{
          wiki_page_id: wiki_page.id,
          content: content,
          version: 1,
          status: :draft
        }

        case Wikis.create_wiki_content(content_attrs) do
          {:ok, _wiki_content} ->
            {:ok, wiki_page}

          {:error, changeset} ->
            {:error, changeset}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp update_wiki_page_content(wiki_page, new_content, content_item) do
    # Get latest content version
    latest_content = Wikis.get_latest_wiki_content(wiki_page.id)

    new_version = if latest_content, do: latest_content.version + 1, else: 1

    content_attrs = %{
      wiki_page_id: wiki_page.id,
      content: new_content,
      version: new_version,
      status: :draft,
      metadata: %{
        content_item_id: content_item.id,
        updated_from_content_item: true,
        synced_at: DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    case Wikis.create_wiki_content(content_attrs) do
      {:ok, _wiki_content} ->
        # Update wiki page metadata
        updated_metadata =
          Map.merge(wiki_page.metadata || %{}, %{
            last_synced_content_item_id: content_item.id,
            last_synced_at: DateTime.utc_now() |> then(&DateTime.to_iso8601/1)
          })

        Wikis.update_wiki_page(wiki_page, %{metadata: updated_metadata})

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp determine_platform_for_content(:blog_post), do: "Company Wiki"
  defp determine_platform_for_content(:github_readme), do: "GitHub"
  defp determine_platform_for_content(:documentation), do: "Documentation"
  defp determine_platform_for_content(:wiki_page), do: "Wikipedia"
  defp determine_platform_for_content(:article), do: "Company Wiki"

  defp determine_platform_for_content(_), do: "Company Wiki"
end

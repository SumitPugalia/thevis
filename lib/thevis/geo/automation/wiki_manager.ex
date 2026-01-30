defmodule Thevis.Geo.Automation.WikiManager do
  @moduledoc """
  Wiki Manager module for automated wiki page creation, updates, and management.
  """

  alias Thevis.Projects.Project
  alias Thevis.Strategy.NarrativeBuilder
  alias Thevis.Wikis
  alias Thevis.Wikis.WikiContent
  alias Thevis.Wikis.WikiPage

  @doc """
  Creates a wiki page for a project from a narrative.
  """
  def create_wiki_page(%Project{} = project, platform_name, page_type \\ :product) do
    narrative = NarrativeBuilder.get_active_narrative(project)

    if narrative do
      wiki_content = generate_wiki_content(narrative, page_type)
      platform = Wikis.get_wiki_platform_by_name(platform_name)

      if platform do
        create_wiki_page_with_content(project, platform, page_type, wiki_content)
      else
        {:error, :platform_not_found}
      end
    else
      {:error, :narrative_not_found}
    end
  end

  @doc """
  Updates a wiki page with new content from narrative.
  """
  def update_wiki_page(%WikiPage{} = wiki_page, %Project{} = project) do
    narrative = NarrativeBuilder.get_active_narrative(project)

    if narrative do
      new_content = generate_wiki_content(narrative, wiki_page.page_type)
      latest_content = Wikis.get_latest_wiki_content(wiki_page.id)

      new_version = if latest_content, do: latest_content.version + 1, else: 1

      attrs = %{
        wiki_page_id: wiki_page.id,
        content: new_content,
        version: new_version,
        is_published: false
      }

      case Wikis.create_wiki_content(attrs) do
        {:ok, wiki_content} -> {:ok, wiki_content}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, :narrative_not_found}
    end
  end

  @doc """
  Publishes a wiki page to the platform.
  """
  def publish_wiki_page(%WikiPage{} = wiki_page) do
    latest_content = Wikis.get_latest_wiki_content(wiki_page.id)

    if latest_content do
      handle_publish_result(wiki_page, latest_content)
    else
      {:error, :no_content}
    end
  end

  defp handle_publish_result(wiki_page, latest_content) do
    case publish_to_platform(wiki_page, latest_content) do
      {:ok, external_id, url} ->
        update_and_publish_content(wiki_page, latest_content, external_id, url)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp update_and_publish_content(wiki_page, latest_content, external_id, url) do
    attrs = %{
      status: :published,
      external_id: external_id,
      url: url
    }

    case Wikis.update_wiki_page(wiki_page, attrs) do
      {:ok, updated_page} ->
        Wikis.publish_wiki_content(latest_content)
        {:ok, updated_page}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Syncs wiki pages with narrative changes.
  """
  def sync_wiki_pages(%Project{} = project) do
    wiki_pages = Wikis.list_wiki_pages(project.id)

    results =
      Enum.map(wiki_pages, fn wiki_page ->
        case update_wiki_page(wiki_page, project) do
          {:ok, _content} -> {:ok, wiki_page}
          {:error, reason} -> {:error, wiki_page, reason}
        end
      end)

    {:ok, results}
  end

  defp create_wiki_page_with_content(project, platform, page_type, content) do
    title = generate_wiki_title(project, page_type)

    page_attrs = %{
      project_id: project.id,
      platform_id: platform.id,
      title: title,
      status: :draft,
      page_type: page_type
    }

    case Wikis.create_wiki_page(page_attrs) do
      {:ok, wiki_page} ->
        content_attrs = %{
          wiki_page_id: wiki_page.id,
          content: content,
          version: 1,
          is_published: false
        }

        case Wikis.create_wiki_content(content_attrs) do
          {:ok, wiki_content} -> {:ok, wiki_page, wiki_content}
          {:error, changeset} -> {:error, changeset}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp generate_wiki_content(narrative, page_type) do
    # Simple wiki content generation - can be enhanced with AI
    base_content = narrative.content

    case page_type do
      :product ->
        """
        # Product Overview

        #{base_content}

        ## Features
        - Feature 1
        - Feature 2
        - Feature 3

        ## Use Cases
        - Use case 1
        - Use case 2
        """

      :company ->
        """
        # Company Overview

        #{base_content}

        ## History
        Founded with a mission to deliver innovative solutions.

        ## Services
        - Service 1
        - Service 2
        """

      :service ->
        """
        # Service Overview

        #{base_content}

        ## Service Details
        Comprehensive service offering designed to meet client needs.
        """
    end
  end

  defp generate_wiki_title(project, page_type) do
    project_name = project.name || "Project"

    case page_type do
      :product -> "#{project_name} Product"
      :company -> "#{project_name} Company"
      :service -> "#{project_name} Service"
    end
  end

  defp publish_to_platform(%WikiPage{} = wiki_page, %WikiContent{} = content) do
    platform = Wikis.get_wiki_platform!(wiki_page.platform_id)

    case platform.platform_type do
      "wikipedia" ->
        publish_to_wikipedia(wiki_page, content)

      "confluence" ->
        publish_to_confluence(wiki_page, content, platform)

      "notion" ->
        publish_to_notion(wiki_page, content, platform)

      _ ->
        {:error, :unsupported_platform}
    end
  end

  defp publish_to_wikipedia(_wiki_page, _content) do
    # Placeholder for Wikipedia API integration
    # This would integrate with Wikipedia API
    {:ok, "wikipedia-page-id", "https://en.wikipedia.org/wiki/Example"}
  end

  defp publish_to_confluence(_wiki_page, _content, _platform) do
    # Placeholder for Confluence API integration
    {:ok, "confluence-page-id", "https://confluence.example.com/pages/123"}
  end

  defp publish_to_notion(_wiki_page, _content, _platform) do
    # Placeholder for Notion API integration
    {:ok, "notion-page-id", "https://notion.so/example"}
  end
end

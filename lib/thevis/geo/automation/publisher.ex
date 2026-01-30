defmodule Thevis.Geo.Automation.Publisher do
  @moduledoc """
  Multi-platform Publisher for publishing content to various platforms.
  """

  alias Thevis.Automation
  alias Thevis.Automation.ContentItem
  alias Thevis.Integrations
  alias Thevis.Integrations.BlogClient
  alias Thevis.Integrations.GitHubClient
  alias Thevis.Integrations.MediumClient
  alias Thevis.Projects

  @doc """
  Publishes a wiki page to a platform.
  """
  def publish_wiki_page(wiki_content, _platform, _options \\ %{}) do
    alias Thevis.Geo.Automation.WikiManager
    alias Thevis.Wikis

    wiki_page = Wikis.get_wiki_page!(wiki_content.wiki_page_id)

    case WikiManager.publish_wiki_page(wiki_page) do
      {:ok, updated_page} -> {:ok, updated_page.url}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Publishes content to Wikipedia.
  """
  def publish_to_wikipedia(wiki_content, _options \\ %{}) do
    publish_wiki_page(wiki_content, "Wikipedia", %{})
  end

  @doc """
  Publishes content to company wiki.
  """
  def publish_to_company_wiki(wiki_content, _options \\ %{}) do
    publish_wiki_page(wiki_content, "Company Wiki", %{})
  end

  @doc """
  Publishes content to GitHub.
  """
  def publish_to_github(content_item, repository, options \\ %{}) do
    [owner, repo_name] = String.split(repository, "/", parts: 2)
    _file_path = Map.get(options, :file_path, "README.md")
    branch = Map.get(options, :branch, "main")

    case GitHubClient.update_readme(owner, repo_name, content_item.content, branch) do
      {:ok, url} -> {:ok, url}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Publishes content to Medium.
  """
  def publish_to_medium(content_item, options \\ %{}) do
    tags = Map.get(options, :tags, [])
    publish_status = Map.get(options, :publish_status, "draft")

    case MediumClient.publish_article(
           content_item.title,
           content_item.content,
           tags,
           publish_status
         ) do
      {:ok, url} -> {:ok, url}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Publishes content to blog.
  """
  def publish_to_blog(content_item, options \\ %{}) do
    metadata = %{
      status: Map.get(options, :status, "draft"),
      categories: Map.get(options, :categories, []),
      tags: Map.get(options, :tags, [])
    }

    case BlogClient.publish_article(content_item.title, content_item.content, metadata) do
      {:ok, url} -> {:ok, url}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Schedules publication of content.
  """
  def schedule_publication(%ContentItem{} = content_item, _platform, schedule_time) do
    Automation.update_content_item(content_item, %{
      status: :scheduled,
      scheduled_at: schedule_time
    })
  end

  @doc """
  Publishes a content item to its target platform.
  """
  def publish_content_item(%ContentItem{} = content_item) do
    case publish_by_platform(content_item) do
      {:ok, url} ->
        Automation.update_content_item(content_item, %{
          status: :published,
          published_url: url,
          published_at: DateTime.utc_now()
        })

      {:error, reason} ->
        Automation.update_content_item(content_item, %{
          status: :failed
        })

        {:error, reason}
    end
  end

  defp publish_by_platform(%ContentItem{platform: :github} = content_item) do
    # Extract repository from project settings or campaign metadata
    repository = extract_repository(content_item)
    publish_to_github(content_item, repository, %{})
  end

  defp publish_by_platform(%ContentItem{platform: :medium} = content_item) do
    options = extract_medium_options(content_item)
    publish_to_medium(content_item, options)
  end

  defp publish_by_platform(%ContentItem{platform: :blog} = content_item) do
    options = extract_blog_options(content_item)
    publish_to_blog(content_item, options)
  end

  defp publish_by_platform(%ContentItem{platform: :wikipedia}) do
    # Would need wiki_content reference
    {:error, :wiki_content_required}
  end

  defp publish_by_platform(%ContentItem{platform: :company_wiki}) do
    # Would need wiki_content reference
    {:error, :wiki_content_required}
  end

  defp publish_by_platform(_content_item) do
    {:error, :unsupported_platform}
  end

  defp extract_repository(content_item) do
    # Try to get from platform settings first, then project settings
    case Integrations.get_platform_setting_by_type(content_item.project_id, "github") do
      %{settings: settings} when is_map(settings) ->
        Map.get(settings, "repository") || Map.get(settings, "repo") || "example/repo"

      _ ->
        # Fallback to project settings
        project = Projects.get_project(content_item.project_id)

        if project do
          settings = project.settings || %{}
          Map.get(settings, "github_repository", "example/repo")
        else
          "example/repo"
        end
    end
  end

  defp extract_medium_options(content_item) do
    # Extract from platform settings
    case Integrations.get_platform_setting_by_type(content_item.project_id, "medium") do
      %{settings: settings} when is_map(settings) ->
        %{
          tags: Map.get(settings, "tags", []),
          publish_status: Map.get(settings, "publish_status", "draft")
        }

      _ ->
        %{
          tags: [],
          publish_status: "draft"
        }
    end
  end

  defp extract_blog_options(content_item) do
    # Extract from platform settings
    case Integrations.get_platform_setting_by_type(content_item.project_id, "blog") do
      %{settings: settings} when is_map(settings) ->
        %{
          status: Map.get(settings, "status", "draft"),
          categories: Map.get(settings, "categories", []),
          tags: Map.get(settings, "tags", [])
        }

      _ ->
        %{
          status: "draft",
          categories: [],
          tags: []
        }
    end
  end
end

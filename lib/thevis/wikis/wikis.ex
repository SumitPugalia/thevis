defmodule Thevis.Wikis do
  @moduledoc """
  The Wikis context for managing wiki pages, platforms, and content.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Wikis.WikiContent
  alias Thevis.Wikis.WikiPage
  alias Thevis.Wikis.WikiPlatform

  ## Wiki Platforms

  @doc """
  Returns the list of wiki platforms.
  """
  def list_wiki_platforms(filters \\ %{}) do
    base_query = from(p in WikiPlatform)

    base_query
    |> apply_platform_filters(filters)
    |> Repo.all()
  end

  @doc """
  Gets a single wiki platform.
  """
  def get_wiki_platform!(id), do: Repo.get!(WikiPlatform, id)

  @doc """
  Gets a wiki platform by name.
  """
  def get_wiki_platform_by_name(name) do
    Repo.get_by(WikiPlatform, name: name)
  end

  @doc """
  Creates a wiki platform.
  """
  def create_wiki_platform(attrs \\ %{}) do
    %WikiPlatform{}
    |> WikiPlatform.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wiki platform.
  """
  def update_wiki_platform(%WikiPlatform{} = platform, attrs) do
    platform
    |> WikiPlatform.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wiki platform.
  """
  def delete_wiki_platform(%WikiPlatform{} = platform) do
    Repo.delete(platform)
  end

  ## Wiki Pages

  @doc """
  Returns the list of wiki pages for a project.
  """
  def list_wiki_pages(project_id, filters \\ %{}) do
    base_query =
      from(wp in WikiPage, where: wp.project_id == ^project_id)
      |> preload([:project, :platform])

    base_query
    |> apply_page_filters(filters)
    |> order_by([wp], desc: wp.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single wiki page.
  """
  def get_wiki_page!(id), do: Repo.get!(WikiPage, id)

  @doc """
  Gets a wiki page by external ID and platform.
  """
  def get_wiki_page_by_external(platform_id, external_id) do
    Repo.get_by(WikiPage, platform_id: platform_id, external_id: external_id)
  end

  @doc """
  Gets a wiki page by title for a project.
  """
  def get_wiki_page_by_title(project_id, title) do
    query =
      from(wp in WikiPage,
        where: wp.project_id == ^project_id,
        where: wp.title == ^title
      )

    Repo.one(query)
  end

  @doc """
  Creates a wiki page.
  """
  def create_wiki_page(attrs \\ %{}) do
    %WikiPage{}
    |> WikiPage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wiki page.
  """
  def update_wiki_page(%WikiPage{} = wiki_page, attrs) do
    wiki_page
    |> WikiPage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wiki page.
  """
  def delete_wiki_page(%WikiPage{} = wiki_page) do
    Repo.delete(wiki_page)
  end

  ## Wiki Contents

  @doc """
  Returns the list of wiki contents for a wiki page.
  """
  def list_wiki_contents(wiki_page_id) do
    query =
      from(wc in WikiContent,
        where: wc.wiki_page_id == ^wiki_page_id,
        order_by: [desc: wc.version]
      )

    Repo.all(query)
  end

  @doc """
  Gets a single wiki content.
  """
  def get_wiki_content!(id), do: Repo.get!(WikiContent, id)

  @doc """
  Gets the latest wiki content for a page.
  """
  def get_latest_wiki_content(wiki_page_id) do
    query =
      from(wc in WikiContent,
        where: wc.wiki_page_id == ^wiki_page_id,
        order_by: [desc: wc.version],
        limit: 1
      )

    Repo.one(query)
  end

  @doc """
  Gets the published wiki content for a page.
  """
  def get_published_wiki_content(wiki_page_id) do
    query =
      from(wc in WikiContent,
        where: wc.wiki_page_id == ^wiki_page_id,
        where: wc.is_published == true,
        order_by: [desc: wc.version],
        limit: 1
      )

    Repo.one(query)
  end

  @doc """
  Creates a wiki content.
  """
  def create_wiki_content(attrs \\ %{}) do
    %WikiContent{}
    |> WikiContent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wiki content.
  """
  def update_wiki_content(%WikiContent{} = wiki_content, attrs) do
    wiki_content
    |> WikiContent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wiki content.
  """
  def delete_wiki_content(%WikiContent{} = wiki_content) do
    Repo.delete(wiki_content)
  end

  @doc """
  Marks a wiki content as published.
  """
  def publish_wiki_content(%WikiContent{} = wiki_content) do
    update_wiki_content(wiki_content, %{
      is_published: true,
      published_at: DateTime.utc_now()
    })
  end

  defp apply_platform_filters(query, %{platform_type: platform_type}) do
    where(query, [p], p.platform_type == ^platform_type)
  end

  defp apply_platform_filters(query, %{is_active: is_active}) do
    where(query, [p], p.is_active == ^is_active)
  end

  defp apply_platform_filters(query, _), do: query

  defp apply_page_filters(query, %{status: status}) do
    where(query, [wp], wp.status == ^status)
  end

  defp apply_page_filters(query, %{page_type: page_type}) do
    where(query, [wp], wp.page_type == ^page_type)
  end

  defp apply_page_filters(query, %{platform_id: platform_id}) do
    where(query, [wp], wp.platform_id == ^platform_id)
  end

  defp apply_page_filters(query, _), do: query
end

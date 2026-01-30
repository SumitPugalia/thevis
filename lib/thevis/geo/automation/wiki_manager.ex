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
        publish_to_wikipedia(wiki_page, content, platform)

      "confluence" ->
        publish_to_confluence(wiki_page, content, platform)

      "notion" ->
        publish_to_notion(wiki_page, content, platform)

      _ ->
        {:error, :unsupported_platform}
    end
  end

  defp publish_to_wikipedia(wiki_page, content, platform) do
    api_url = platform.api_endpoint || "https://en.wikipedia.org/w/api.php"
    username = get_platform_config(platform, "username")
    password = platform.api_key

    if is_nil(password) or is_nil(username) or password == "" or username == "" do
      {:error, :not_configured}
    else
      case fetch_mediawiki_edit_token(api_url, username, password) do
        {:ok, token, cookie} ->
          do_mediawiki_edit(api_url, wiki_page.title, content.content, token, cookie)

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp fetch_mediawiki_edit_token(api_url, username, password) do
    # Get login token
    case Req.get(api_url,
           params: [action: "query", meta: "tokens", type: "login", format: "json"]
         ) do
      {:ok, %{status: 200, body: %{"query" => %{"tokens" => %{"logintoken" => lgtoken}}}}} ->
        # Login
        login_body = [
          {"action", "login"},
          {"lgname", username},
          {"lgpassword", password},
          {"lgtoken", String.trim(lgtoken)},
          {"format", "json"}
        ]

        case Req.post(api_url,
               body: login_body,
               headers: [{"content-type", "application/x-www-form-urlencoded"}]
             ) do
          {:ok,
           %{status: 200, body: %{"login" => %{"result" => "Success"}}, headers: resp_headers}} ->
            cookie = get_cookie_from_headers(resp_headers)
            fetch_csrf_after_login(api_url, cookie)

          {:ok, %{body: %{"login" => %{"result" => result}}}} ->
            {:error, {:login_failed, result}}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_mediawiki_edit(api_url, title, text, token, cookie) do
    # Use title from wiki_page; build page URL from api base (e.g. en.wikipedia.org)
    base_domain = api_url |> URI.parse() |> Map.get(:host, "en.wikipedia.org")

    page_slug =
      title |> String.replace(" ", "_") |> URI.encode_www_form() |> String.replace("+", "_")

    page_url = "https://#{base_domain}/wiki/#{page_slug}"

    body = [
      {"action", "edit"},
      {"title", title},
      {"text", text},
      {"token", token},
      {"format", "json"}
    ]

    base_headers = [{"content-type", "application/x-www-form-urlencoded"}]
    req_headers = if cookie, do: [{"Cookie", cookie} | base_headers], else: base_headers

    case Req.post(api_url, body: body, headers: req_headers) do
      {:ok, %{status: 200, body: %{"edit" => %{"result" => "Success", "pageid" => pageid}}}} ->
        {:ok, to_string(pageid), page_url}

      {:ok, %{status: 200, body: %{"edit" => %{"result" => "Success"}}}} ->
        {:ok, title, page_url}

      {:ok, %{status: 200, body: %{"error" => err}}} ->
        {:error, {:api_error, err}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_csrf_after_login(api_url, cookie) do
    base_opts = [params: [action: "query", meta: "tokens", type: "csrf", format: "json"]]

    get_opts =
      if cookie, do: Keyword.put(base_opts, :headers, [{"Cookie", cookie}]), else: base_opts

    case Req.get(api_url, get_opts) do
      {:ok, %{status: 200, body: %{"query" => %{"tokens" => %{"csrftoken" => csrf}}}}} ->
        {:ok, String.trim(csrf), cookie}

      {:ok, %{body: body}} ->
        {:error, {:csrf_failed, body}}
    end
  end

  defp get_cookie_from_headers(headers) when is_map(headers) do
    cookie_val = Map.get(headers, "set-cookie") || Map.get(headers, "Set-Cookie")

    case cookie_val do
      [cookie | _] when is_binary(cookie) ->
        String.split(cookie, ";") |> List.first() |> String.trim()

      _ ->
        nil
    end
  end

  defp get_cookie_from_headers(headers) when is_list(headers) do
    parts =
      headers
      |> Enum.filter(fn {k, _} -> String.downcase(k) == "set-cookie" end)
      |> Enum.map(fn {_, v} -> first_cookie_part(v) end)

    joined = Enum.map_join(parts, "; ", & &1)
    if joined == "", do: nil, else: joined
  end

  # credo:disable-for-next-line Credo.Check.Readability.NestedFunctionCalls
  defp first_cookie_part(v) when is_binary(v), do: List.first(String.split(v, ";")) || v
  defp first_cookie_part(v), do: to_string(v)

  defp publish_to_confluence(wiki_page, content, platform) do
    base_url = platform.api_endpoint
    token = platform.api_key
    space_key = get_platform_config(platform, "space_key")

    if is_nil(base_url) or base_url == "" or is_nil(token) or token == "" or is_nil(space_key) or
         space_key == "" do
      {:error, :not_configured}
    else
      url = base_url |> String.trim_trailing("/") |> then(&"#{&1}/rest/api/content")
      html_content = content.content |> String.replace("\n", "<p>") |> then(&"<p>#{&1}</p>")

      body =
        Jason.encode!(%{
          "type" => "page",
          "title" => wiki_page.title,
          "space" => %{"key" => space_key},
          "body" => %{
            "storage" => %{
              "value" => html_content,
              "representation" => "storage"
            }
          }
        })

      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ]

      case Req.post(url, body: body, headers: headers) do
        {:ok, %{status: 200, body: %{"id" => id, "_links" => %{"webui" => webui}}}}
        when is_binary(webui) ->
          page_url = base_url |> String.trim_trailing("/") |> then(&"#{&1}#{webui}")
          {:ok, to_string(id), page_url}

        {:ok, %{status: 200, body: %{"id" => id}}} ->
          {:ok, to_string(id), "#{base_url}/pages/viewpage.action?pageId=#{id}"}

        {:ok, %{status: 201, body: %{"id" => id}}} ->
          {:ok, to_string(id), "#{base_url}/pages/viewpage.action?pageId=#{id}"}

        {:ok, %{status: status, body: body_response}} ->
          {:error, {:api_error, status, body_response}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp publish_to_notion(wiki_page, content, platform) do
    token = platform.api_key
    parent_page_id = get_platform_config(platform, "parent_page_id")

    if is_nil(token) or token == "" or is_nil(parent_page_id) or parent_page_id == "" do
      {:error, :not_configured}
    else
      url = "https://api.notion.com/v1/pages"

      # Notion expects block children for body; title in properties
      body =
        Jason.encode!(%{
          "parent" => %{"page_id" => String.replace(parent_page_id, "-", "")},
          "properties" => %{
            "title" => %{
              "title" => [%{"type" => "text", "text" => %{"content" => wiki_page.title}}]
            }
          },
          "children" => [
            %{
              "object" => "block",
              "type" => "paragraph",
              "paragraph" => %{
                "rich_text" => [
                  %{
                    "type" => "text",
                    "text" => %{"content" => String.slice(content.content, 0, 2000)}
                  }
                ]
              }
            }
          ]
        })

      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"Notion-Version", "2022-06-28"}
      ]

      case Req.post(url, body: body, headers: headers) do
        {:ok, %{status: 200, body: %{"id" => id, "url" => notion_url}}} ->
          {:ok, id, notion_url}

        {:ok, %{status: status, body: body_response}} ->
          {:error, {:api_error, status, body_response}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp get_platform_config(platform, key) do
    config = platform.config || %{}
    Map.get(config, key) || Map.get(config, to_string(key))
  end
end

defmodule Thevis.Geo.Crawler do
  @moduledoc """
  Web crawler for extracting content from various sources for authority analysis.
  """

  alias Thevis.Accounts.Company
  alias Thevis.Integrations.GitHubClient
  alias Thevis.Integrations.NewsApiClient
  alias Thevis.Products.Product

  @doc """
  Crawls a source for a given optimizable entity (product or company).
  """
  def crawl_source(source_type, optimizable, opts \\ [])

  def crawl_source(:github, %Product{} = product, opts) do
    crawl_github(product, opts)
  end

  def crawl_source(:github, %Company{} = company, opts) do
    crawl_github(company, opts)
  end

  def crawl_source(:medium, %Product{} = product, opts) do
    crawl_medium(product, opts)
  end

  def crawl_source(:medium, %Company{} = company, opts) do
    crawl_medium(company, opts)
  end

  def crawl_source(:news, %Product{} = product, opts) do
    crawl_news(product, opts)
  end

  def crawl_source(:news, %Company{} = company, opts) do
    crawl_news(company, opts)
  end

  def crawl_source(:website, %Company{} = company, opts) do
    crawl_website(company, opts)
  end

  def crawl_source(_source_type, _optimizable, _opts) do
    {:error, :unsupported_source_type}
  end

  @doc """
  Crawls GitHub repositories for a product or company.
  Uses opts[:repo] or opts["repo"] as "owner/name" when set; otherwise searches GitHub for the optimizable name.
  """
  def crawl_github(optimizable, opts \\ []) do
    repo = opts[:repo] || opts["repo"]

    result =
      if repo && is_binary(repo) do
        [owner, name] = String.split(repo, "/", parts: 2)
        fetch_github_repo_content(owner, name, optimizable.name)
      else
        search_and_fetch_github(optimizable.name)
      end

    case result do
      {:ok, data} ->
        {:ok, data}

      {:error, _reason} ->
        {:ok,
         %{
           source_type: :github,
           source_url: "https://github.com/search?q=#{URI.encode(optimizable.name)}",
           title: "#{optimizable.name} on GitHub",
           content: "No repository content found for #{optimizable.name}",
           metadata: %{repo_name: optimizable.name}
         }}
    end
  end

  defp fetch_github_repo_content(owner, name, _search_name) do
    case GitHubClient.get_readme(owner, name) do
      {:ok, content} ->
        {:ok,
         %{
           source_type: :github,
           source_url: "https://github.com/#{owner}/#{name}",
           title: "#{name} on GitHub",
           content: content,
           metadata: %{repo_owner: owner, repo_name: name}
         }}

      {:error, _} ->
        {:error, :readme_not_found}
    end
  end

  defp search_and_fetch_github(search_name) do
    case GitHubClient.search_repositories(search_name, per_page: 3) do
      {:ok, [%{html_url: url, owner: owner, name: name} | _]} ->
        case fetch_github_repo_content(owner, name, search_name) do
          {:ok, data} -> {:ok, Map.put(data, :source_url, url)}
          err -> err
        end

      {:ok, []} ->
        {:error, :no_repos_found}

      {:error, _} ->
        {:error, :search_failed}
    end
  end

  @doc """
  Crawls Medium for articles mentioning the optimizable.
  Fetches the Medium search page and extracts text (no public search API).
  """
  def crawl_medium(optimizable, opts \\ []) do
    query = optimizable.name
    search_url = "https://medium.com/search?q=#{URI.encode(query)}"
    timeout = Keyword.get(opts, :timeout, 10_000)

    case fetch_medium_search(search_url, timeout) do
      {:ok, content} ->
        {:ok,
         %{
           source_type: :medium,
           source_url: search_url,
           title: "Articles about #{query}",
           content: content,
           metadata: %{search_query: query}
         }}

      {:error, _reason} ->
        {:ok,
         %{
           source_type: :medium,
           source_url: search_url,
           title: "Articles about #{query}",
           content: "",
           metadata: %{search_query: query}
         }}
    end
  end

  defp fetch_medium_search(url, timeout) do
    headers = [
      {"User-Agent", "thevis-crawler/1.0 (AI visibility optimization; +https://thevis.ai)"}
    ]

    case Thevis.HTTP.get(url, headers: headers, receive_timeout: timeout) do
      {:ok, body} when is_binary(body) ->
        {:ok, extract_content(body)}

      {:error, _reason} ->
        {:error, :fetch_failed}
    end
  end

  @doc """
  Crawls news articles for a product or company via NewsAPI.org.
  Set NEWS_API_KEY in config or env; otherwise returns empty content.
  """
  def crawl_news(optimizable, opts \\ []) do
    query = optimizable.name
    page_size = Keyword.get(opts, :page_size, 5)

    case NewsApiClient.fetch_everything(query, page_size: page_size) do
      {:ok, articles} when is_list(articles) and articles != [] ->
        content =
          Enum.map_join(articles, "\n\n", fn a ->
            [a[:title], a[:description], a[:content]]
            |> Enum.reject(&is_nil/1)
            |> Enum.join(" ")
          end)

        {:ok,
         %{
           source_type: :news,
           source_url: "https://news.google.com/search?q=#{URI.encode(query)}",
           title: "News about #{query}",
           content: content,
           metadata: %{search_query: query, article_count: length(articles)}
         }}

      {:ok, []} ->
        {:ok,
         %{
           source_type: :news,
           source_url: "https://news.google.com/search?q=#{URI.encode(query)}",
           title: "News about #{query}",
           content: "No articles found for #{query}",
           metadata: %{search_query: query}
         }}

      {:error, _reason} ->
        {:ok,
         %{
           source_type: :news,
           source_url: "https://news.google.com/search?q=#{URI.encode(query)}",
           title: "News about #{query}",
           content: "",
           metadata: %{search_query: query}
         }}
    end
  end

  @doc """
  Crawls company website for content via HTTP and HTML parsing.
  """
  def crawl_website(%Company{} = company, opts \\ []) do
    if company.website_url do
      timeout = Keyword.get(opts, :timeout, 10_000)

      case fetch_website_content(company.website_url, timeout) do
        {:ok, content} ->
          {:ok,
           %{
             source_type: :website,
             source_url: company.website_url,
             title: "#{company.name} Website",
             content: content,
             metadata: %{domain: company.domain}
           }}

        {:error, reason} ->
          {:ok,
           %{
             source_type: :website,
             source_url: company.website_url,
             title: "#{company.name} Website",
             content: "",
             metadata: %{domain: company.domain, fetch_error: inspect(reason)}
           }}
      end
    else
      {:error, :no_website_url}
    end
  end

  defp fetch_website_content(url, timeout) do
    headers = [
      {"User-Agent", "thevis-crawler/1.0 (AI visibility optimization; +https://thevis.ai)"}
    ]

    case Thevis.HTTP.get(url, headers: headers, receive_timeout: timeout) do
      {:ok, body} when is_binary(body) ->
        {:ok, extract_content(body)}

      {:error, :redirect} ->
        {:error, :redirect_not_followed}

      {:error, :api_error} ->
        {:error, {:http_status, :api_error}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Extracts text content from HTML using Floki when available.
  """
  def extract_content(html) when is_binary(html) do
    case Floki.parse_document(html) do
      {:ok, doc} ->
        doc
        |> Floki.filter_out("script")
        |> Floki.filter_out("style")
        |> Floki.filter_out("noscript")
        |> Floki.text(deep: true)
        |> String.replace(~r/\s+/u, " ")
        |> String.trim()

      {:error, _} ->
        # Fallback: strip tags with regex
        html
        |> String.replace(~r/<[^>]+>/, " ")
        |> String.replace(~r/\s+/u, " ")
        |> String.trim()
    end
  end

  def extract_content(_), do: ""
end

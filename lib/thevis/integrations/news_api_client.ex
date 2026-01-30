defmodule Thevis.Integrations.NewsApiClient do
  @moduledoc """
  NewsAPI.org client for fetching news articles (v2 everything endpoint).
  Set NEWS_API_KEY in config or env for crawl_news integration.
  """

  @api_url Application.compile_env(:thevis, [__MODULE__, :api_url], "https://newsapi.org/v2")

  @doc """
  Searches news articles by query. Returns {:ok, articles} or {:error, reason}.
  articles is a list of maps with :title, :description, :url, :published_at, :source_name.
  """
  def fetch_everything(query, opts \\ []) when is_binary(query) do
    api_key = get_api_key()
    page_size = Keyword.get(opts, :page_size, 5)

    if is_nil(api_key) or api_key == "" do
      {:error, :no_api_key}
    else
      fetch_news_articles(query, api_key, page_size)
    end
  end

  defp fetch_news_articles(query, api_key, page_size) do
    url = "#{@api_url}/everything"
    params = [q: query, apiKey: api_key, pageSize: page_size, sortBy: "relevancy"]

    case Req.get(url, params: params) do
      {:ok, %{status: 200, body: %{"status" => "ok", "articles" => articles}}} ->
        normalized =
          Enum.map(articles, fn a ->
            %{
              title: a["title"],
              description: a["description"],
              content: a["content"],
              url: a["url"],
              published_at: a["publishedAt"],
              source_name: get_in(a, ["source", "name"])
            }
          end)

        {:ok, normalized}

      {:ok, %{status: 401, body: _}} ->
        {:error, :invalid_api_key}

      {:ok, %{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_api_key do
    config = Application.get_env(:thevis, __MODULE__)

    case config do
      nil ->
        nil

      list when is_list(list) ->
        case Keyword.get(list, :api_key) do
          {_mod, :get_env, [key]} -> System.get_env(key)
          key when is_binary(key) -> key
          _ -> nil
        end

      _ ->
        nil
    end
  end
end

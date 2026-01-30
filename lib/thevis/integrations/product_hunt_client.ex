defmodule Thevis.Integrations.ProductHuntClient do
  @moduledoc """
  Product Hunt API v2 (GraphQL) client for product listings (GEO authority).

  Config: api_key + token via PRODUCT_HUNT_API_KEY and PRODUCT_HUNT_TOKEN.
  Settings: %{"slug" => "product-slug"} or %{"topic" => "slug"} for listing.
  """

  @api_url Application.compile_env(
             :thevis,
             [__MODULE__, :api_url],
             "https://api.producthunt.com/v2/api"
           )

  @doc """
  Fetches product/post by slug.
  Settings: %{"slug" => "product-slug"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"slug" => slug}) when is_binary(slug) and slug != "" do
    token = Thevis.Integrations.get_config_value(__MODULE__, :api_token)
    if is_nil(token) or token == "", do: {:error, :no_api_token}, else: get_post(slug, token)
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_post(slug, token) do
    query = """
    query { post(slug: "#{slug}") { id name tagline url website votesCount commentsCount } }
    """

    body = %{query: query}

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ]

    case Thevis.HTTP.post(@api_url, json: body, headers: headers) do
      {:ok, %{"data" => %{"post" => post}}} when is_map(post) ->
        {:ok,
         %{
           name: post["name"],
           tagline: post["tagline"],
           profile_url: post["url"],
           website: post["website"],
           votes_count: post["votesCount"],
           comments_count: post["commentsCount"]
         }}

      {:ok, %{"data" => %{"post" => nil}}} ->
        {:error, :not_found}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

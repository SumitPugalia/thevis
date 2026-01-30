defmodule Thevis.Integrations.YelpClient do
  @moduledoc """
  Yelp Fusion API v3 client for business profiles (GEO authority signal).

  Config: api_key via YELP_API_KEY or Application config.
  Settings map: %{"business_id" => "yelp-business-id"}.

  See: https://docs.developer.yelp.com/docs/fusion-intro
  """

  @api_url Application.compile_env(:thevis, [__MODULE__, :api_url], "https://api.yelp.com/v3")

  @doc """
  Fetches business details (rating, review count, URL).
  Settings: %{"business_id" => "yelp-business-id"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"business_id" => id}) when is_binary(id) and id != "" do
    api_key = Thevis.Integrations.get_config_value(__MODULE__, :api_key)

    if is_nil(api_key) or api_key == "",
      do: {:error, :no_api_key},
      else: get_business(id, api_key)
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_business(id, api_key) do
    url = "#{@api_url}/businesses/#{URI.encode(id)}"
    headers = [{"Authorization", "Bearer #{api_key}"}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, body} when is_map(body) ->
        {:ok,
         %{
           name: body["name"],
           rating: body["rating"],
           review_count: body["review_count"],
           url: body["url"],
           profile_url: body["url"]
         }}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

defmodule Thevis.Integrations.GoogleBusinessClient do
  @moduledoc """
  Google Business Profile (formerly My Business) API client for location/profile (GEO authority).

  Config: access_token or service account via GOOGLE_BUSINESS_ACCESS_TOKEN / GOOGLE_APPLICATION_CREDENTIALS.
  Settings map: %{"account_id" => "...", "location_id" => "..."} or %{"location_name" => "accounts/.../locations/..."}.

  Requires OAuth2 or service account; typically used to fetch profile and update description.
  See: https://developers.google.com/my-business/reference/rest
  """

  @api_url Application.compile_env(
             :thevis,
             [__MODULE__, :api_url],
             "https://mybusinessbusinessinformation.googleapis.com/v1"
           )

  @doc """
  Fetches location (business profile) details.
  Settings: %{"location_name" => "accounts/123/locations/456"} or account_id + location_id.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"location_name" => name}) when is_binary(name) and name != "" do
    token = Thevis.Integrations.get_config_value(__MODULE__, :access_token)

    if is_nil(token) or token == "",
      do: {:error, :no_access_token},
      else: get_location(name, token)
  end

  def fetch_profile(%{"account_id" => acc_id, "location_id" => loc_id})
      when is_binary(acc_id) and acc_id != "" and is_binary(loc_id) and loc_id != "" do
    name = "accounts/#{acc_id}/locations/#{loc_id}"
    fetch_profile(%{"location_name" => name})
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_location(location_name, token) do
    url = "#{@api_url}/#{URI.encode(location_name)}"
    headers = [{"Authorization", "Bearer #{token}"}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, body} when is_map(body) ->
        {:ok,
         %{
           title: body["title"],
           storefront_address: body["storefrontAddress"],
           profile_url:
             body["regularHours"] &&
               "https://www.google.com/maps/search/?api=1&query=#{URI.encode(body["title"] || "")}"
         }}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

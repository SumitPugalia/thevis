defmodule Thevis.Integrations.TrustpilotClient do
  @moduledoc """
  Trustpilot API client for business profiles and reviews (GEO authority signal).

  Config: api_key via TRUSTPILOT_API_KEY or Application config.
  Settings map: %{"business_unit_id" => "..."} or %{"domain" => "example.com"} to resolve ID.

  See: https://developers.trustpilot.com/
  """

  @api_url Application.compile_env(
             :thevis,
             [__MODULE__, :api_url],
             "https://api.trustpilot.com/v1"
           )

  @doc """
  Fetches business unit profile (TrustScore, review count, profile URL).
  Settings: %{"business_unit_id" => id} or %{"domain" => "example.com"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"business_unit_id" => id}) when is_binary(id) and id != "" do
    api_key = Thevis.Integrations.get_config_value(__MODULE__, :api_key)

    if is_nil(api_key) or api_key == "",
      do: {:error, :no_api_key},
      else: get_business_unit(id, api_key)
  end

  def fetch_profile(%{"domain" => domain}) when is_binary(domain) and domain != "" do
    api_key = Thevis.Integrations.get_config_value(__MODULE__, :api_key)

    if is_nil(api_key) or api_key == "",
      do: {:error, :no_api_key},
      else: find_by_domain(domain, api_key)
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_business_unit(id, api_key) do
    url = "#{@api_url}/business-units/#{URI.encode(id)}"
    headers = [{"Authorization", "Bearer #{api_key}"}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, body} when is_map(body) ->
        {:ok,
         %{
           trust_score: body["score"],
           review_count: body["numberOfReviews"],
           profile_url: body["profileUrl"],
           name: body["displayName"]
         }}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp find_by_domain(domain, api_key) do
    url = "#{@api_url}/business-units/find"
    headers = [{"Authorization", "Bearer #{api_key}"}]
    params = [domain: domain]

    case Thevis.HTTP.get(url, headers: headers, params: params) do
      {:ok, %{"id" => id}} when is_binary(id) ->
        get_business_unit(id, api_key)

      {:ok, _} ->
        {:error, :business_not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

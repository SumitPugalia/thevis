defmodule Thevis.Integrations.LinkedInCompanyClient do
  @moduledoc """
  LinkedIn API client for company page (GEO authority + consistency).

  Config: access_token via LINKEDIN_ACCESS_TOKEN (OAuth2).
  Settings: %{"company_id" => "123"} or %{"vanity_name" => "example-corp"}.
  """

  @api_url Application.compile_env(:thevis, [__MODULE__, :api_url], "https://api.linkedin.com/v2")

  @doc """
  Fetches company page details (name, description, follower count).
  Settings: %{"company_id" => "id"} or %{"vanity_name" => "vanity"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"company_id" => id}) when is_binary(id) and id != "" do
    token = Thevis.Integrations.get_config_value(__MODULE__, :access_token)
    if is_nil(token) or token == "", do: {:error, :no_access_token}, else: get_company(id, token)
  end

  def fetch_profile(%{"vanity_name" => vanity}) when is_binary(vanity) and vanity != "" do
    token = Thevis.Integrations.get_config_value(__MODULE__, :access_token)

    if is_nil(token) or token == "",
      do: {:error, :no_access_token},
      else: get_company_by_vanity(vanity, token)
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_company(id, token) do
    url = "#{@api_url}/organizations/#{URI.encode(id)}"
    headers = [{"Authorization", "Bearer #{token}"}, {"X-Restli-Protocol-Version", "2.0.0"}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, body} when is_map(body) ->
        {:ok,
         %{
           name: body["localizedName"] || body["name"],
           description: body["localizedDescription"],
           profile_url: "https://www.linkedin.com/company/#{id}",
           follower_count: body["followerCount"]
         }}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_company_by_vanity(vanity, token) do
    url = "#{@api_url}/organizations?q=vanityName&vanityName=#{URI.encode(vanity)}"
    headers = [{"Authorization", "Bearer #{token}"}, {"X-Restli-Protocol-Version", "2.0.0"}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, %{"elements" => [%{"id" => id} | _]}} ->
        get_company(id, token)

      {:ok, _} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

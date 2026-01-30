defmodule Thevis.Integrations.FacebookClient do
  @moduledoc """
  Facebook Graph API client for page profile (GEO consistency + authority).

  Config: access_token via FACEBOOK_ACCESS_TOKEN (Page access token).
  Settings: %{"page_id" => "..."} or %{"page_username" => "..."}.
  """

  @api_url Application.compile_env(
             :thevis,
             [__MODULE__, :api_url],
             "https://graph.facebook.com/v18.0"
           )

  @doc """
  Fetches page profile (name, about, follower count).
  Settings: %{"page_id" => "id"} or %{"page_username" => "username"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"page_id" => id}) when is_binary(id) and id != "" do
    token = Thevis.Integrations.get_config_value(__MODULE__, :access_token)
    if is_nil(token) or token == "", do: {:error, :no_access_token}, else: get_page(id, token)
  end

  def fetch_profile(%{"page_username" => username}) when is_binary(username) and username != "" do
    token = Thevis.Integrations.get_config_value(__MODULE__, :access_token)

    if is_nil(token) or token == "",
      do: {:error, :no_access_token},
      else: get_page_by_username(username, token)
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_page(id, token) do
    url = "#{@api_url}/#{URI.encode(id)}"
    params = [access_token: token, fields: "name,about,fan_count,link"]
    headers = [{"Content-Type", "application/json"}]

    case Thevis.HTTP.get(url, headers: headers, params: params) do
      {:ok, body} when is_map(body) ->
        if Map.has_key?(body, "name") do
          {:ok,
           %{
             name: body["name"],
             about: body["about"],
             profile_url: body["link"] || "https://www.facebook.com/#{id}",
             fan_count: body["fan_count"]
           }}
        else
          if Map.has_key?(body, "error"),
            do: {:error, :not_found},
            else: {:error, :unexpected_response}
        end

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_page_by_username(username, token) do
    url = "#{@api_url}/#{URI.encode(username)}"
    params = [access_token: token, fields: "id,name,about,fan_count,link"]
    headers = [{"Content-Type", "application/json"}]

    case Thevis.HTTP.get(url, headers: headers, params: params) do
      {:ok, body} when is_map(body) ->
        if Map.has_key?(body, "id") do
          {:ok,
           %{
             name: body["name"],
             about: body["about"],
             profile_url: body["link"] || "https://www.facebook.com/#{username}",
             fan_count: body["fan_count"]
           }}
        else
          if Map.has_key?(body, "error"),
            do: {:error, :not_found},
            else: {:error, :unexpected_response}
        end

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

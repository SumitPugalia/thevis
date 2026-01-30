defmodule Thevis.Integrations.StackExchangeClient do
  @moduledoc """
  Stack Exchange API client for site/questions (GEO community authority).

  Config: optional api_key via STACK_EXCHANGE_KEY for higher quota.
  Settings: %{"site" => "stackoverflow", "tag" => "product-name"} or %{"user_id" => "..."} for profile.
  """

  @api_url Application.compile_env(
             :thevis,
             [__MODULE__, :api_url],
             "https://api.stackexchange.com/2.3"
           )

  @doc """
  Fetches site info or user profile URL. For tag-based questions use tag.
  Settings: %{"site" => "stackoverflow"}, or %{"user_id" => "123", "site" => "stackoverflow"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"site" => site} = settings) when is_binary(site) and site != "" do
    api_key = Thevis.Integrations.get_config_value(__MODULE__, :api_key)
    params = [key: api_key, site: site] |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)

    if Map.has_key?(settings, "user_id") and settings["user_id"] != "" do
      get_user(settings["user_id"], params)
    else
      get_site_info(site, params)
    end
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_site_info(site, params) do
    url = "#{@api_url}/info"

    case Thevis.HTTP.get(url, params: params) do
      {:ok, %{"items" => [item | _]}} when is_map(item) ->
        {:ok,
         %{
           name: item["name"],
           profile_url: item["site_url"],
           site: site
         }}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_user(user_id, params) do
    url = "#{@api_url}/users/#{URI.encode(user_id)}"

    case Thevis.HTTP.get(url, params: params) do
      {:ok, %{"items" => [item | _]}} when is_map(item) ->
        {:ok,
         %{
           display_name: item["display_name"],
           profile_url: item["link"],
           reputation: item["reputation"]
         }}

      {:ok, _} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

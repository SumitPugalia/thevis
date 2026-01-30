defmodule Thevis.Integrations.CrunchbaseClient do
  @moduledoc """
  Crunchbase API client for company/organization profiles (GEO authority).

  Config: api_key via CRUNCHBASE_API_KEY (Crunchbase Pro/API key).
  Settings: %{"entity_id" => "..."} or %{"permalink" => "organization/example"}.
  """

  @api_url Application.compile_env(
             :thevis,
             [__MODULE__, :api_url],
             "https://api.crunchbase.com/api/v4"
           )

  @doc """
  Fetches entity (organization) profile.
  Settings: %{"entity_id" => "uuid"} or %{"permalink" => "organization/example"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(settings) do
    api_key = Thevis.Integrations.get_config_value(__MODULE__, :api_key)

    if is_nil(api_key) or api_key == "",
      do: {:error, :no_api_key},
      else: get_entity(settings, api_key)
  end

  defp get_entity(%{"entity_id" => id}, api_key) when is_binary(id) and id != "" do
    url = "#{@api_url}/entities/organization/#{URI.encode(id)}"
    get_with_key(url, api_key)
  end

  defp get_entity(%{"permalink" => perm}, api_key) when is_binary(perm) and perm != "" do
    url = "#{@api_url}/entities/organization/#{URI.encode(perm)}"
    get_with_key(url, api_key)
  end

  defp get_entity(_, _), do: {:error, :invalid_settings}

  defp get_with_key(url, api_key) do
    headers = [{"X-cb-user-key", api_key}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, body} when is_map(body) ->
        props = body["properties"] || body

        {:ok,
         %{
           name: props["name"],
           profile_url:
             props["website_url"] ||
               "https://www.crunchbase.com/organization/#{props["permalink"]}",
           short_description: props["short_description"]
         }}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

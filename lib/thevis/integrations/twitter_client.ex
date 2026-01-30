defmodule Thevis.Integrations.TwitterClient do
  @moduledoc """
  Twitter / X API v2 client for user/company profile (GEO consistency + authority).

  Config: bearer_token via TWITTER_BEARER_TOKEN (OAuth2 app-only).
  Settings: %{"username" => "handle"} (without @).
  """

  @api_url Application.compile_env(:thevis, [__MODULE__, :api_url], "https://api.twitter.com/2")

  @doc """
  Fetches user by username (profile description, follower count).
  Settings: %{"username" => "handle"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"username" => username}) when is_binary(username) and username != "" do
    token = Thevis.Integrations.get_config_value(__MODULE__, :bearer_token)

    if is_nil(token) or token == "",
      do: {:error, :no_bearer_token},
      else: get_user(username, token)
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_user(username, token) do
    username = String.trim_leading(username, "@")
    url = "#{@api_url}/users/by/username/#{URI.encode(username)}"
    headers = [{"Authorization", "Bearer #{token}"}]
    params = %{"user.fields" => "description,public_metrics,profile_image_url"}

    case Thevis.HTTP.get(url, headers: headers, params: params) do
      {:ok, %{"data" => data}} when is_map(data) ->
        metrics = data["public_metrics"] || %{}

        {:ok,
         %{
           name: data["name"],
           username: data["username"],
           description: data["description"],
           profile_url: "https://twitter.com/#{data["username"]}",
           follower_count: metrics["followers_count"]
         }}

      {:ok, %{"errors" => _}} ->
        {:error, :not_found}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

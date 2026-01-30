defmodule Thevis.Integrations.RedditClient do
  @moduledoc """
  Reddit API client for subreddit or user (GEO community authority).

  Config: client_id + client_secret via REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET (OAuth2).
  Settings: %{"subreddit" => "name"} or %{"username" => "..."} for profile URL.
  """

  @api_url Application.compile_env(:thevis, [__MODULE__, :api_url], "https://oauth.reddit.com")

  @doc """
  Fetches subreddit info (title, description, subscriber count) or returns profile URL for user.
  Settings: %{"subreddit" => "subredditname"} or %{"username" => "username"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"subreddit" => sub}) when is_binary(sub) and sub != "" do
    token = get_access_token()

    if is_nil(token),
      do: {:error, :no_credentials},
      else: get_subreddit(String.trim_leading(sub, "r/"), token)
  end

  def fetch_profile(%{"username" => username}) when is_binary(username) and username != "" do
    {:ok,
     %{
       profile_url: "https://www.reddit.com/user/#{URI.encode(username)}",
       username: username,
       source: "reddit"
     }}
  end

  def fetch_profile(_), do: {:error, :invalid_settings}

  defp get_access_token do
    client_id = Thevis.Integrations.get_config_value(__MODULE__, :client_id)
    client_secret = Thevis.Integrations.get_config_value(__MODULE__, :client_secret)

    if is_nil(client_id) or is_nil(client_secret),
      do: nil,
      else: request_token(client_id, client_secret)
  end

  defp request_token(client_id, client_secret) do
    url = "https://www.reddit.com/api/v1/access_token"

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Basic #{Base.encode64("#{client_id}:#{client_secret}")}"}
    ]

    body = "grant_type=client_credentials"

    case Thevis.HTTP.post(url, body: body, headers: headers) do
      {:ok, %{"access_token" => token}} -> token
      _ -> nil
    end
  end

  defp get_subreddit(name, token) do
    url = "#{@api_url}/r/#{URI.encode(name)}/about"
    headers = [{"Authorization", "Bearer #{token}"}, {"User-Agent", "thevis/1.0"}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, %{"data" => data}} when is_map(data) ->
        {:ok,
         %{
           title: data["title"],
           public_description: data["public_description"],
           subscriber_count: data["subscribers"],
           profile_url: "https://www.reddit.com/r/#{name}"
         }}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

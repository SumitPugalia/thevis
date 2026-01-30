defmodule Thevis.Integrations.HackerNewsClient do
  @moduledoc """
  Hacker News API client for user/item (GEO community authority).

  Uses public Firebase-based API; no key required.
  Settings: %{"username" => "..."} for user profile, or %{"item_id" => "123"} for story.
  """

  @api_url Application.compile_env(
             :thevis,
             [__MODULE__, :api_url],
             "https://hacker-news.firebaseio.com/v0"
           )

  @doc """
  Fetches user profile (karma, about) or item (story) by ID.
  Settings: %{"username" => "handle"} or %{"item_id" => "123"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"username" => username}) when is_binary(username) and username != "" do
    url = "#{@api_url}/user/#{URI.encode(username)}.json"

    case Thevis.HTTP.get(url) do
      {:ok, %{"id" => _} = body} ->
        {:ok,
         %{
           id: body["id"],
           karma: body["karma"],
           about: body["about"],
           profile_url: "https://news.ycombinator.com/user?id=#{URI.encode(username)}"
         }}

      {:ok, nil} ->
        {:error, :not_found}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_profile(%{"item_id" => id}) when is_binary(id) and id != "" do
    url = "#{@api_url}/item/#{URI.encode(id)}.json"

    case Thevis.HTTP.get(url) do
      {:ok, %{"id" => _} = body} ->
        {:ok,
         %{
           id: body["id"],
           title: body["title"],
           url: body["url"],
           score: body["score"],
           profile_url: "https://news.ycombinator.com/item?id=#{id}"
         }}

      {:ok, nil} ->
        {:error, :not_found}

      {:ok, _} ->
        {:error, :unexpected_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_profile(_), do: {:error, :invalid_settings}
end

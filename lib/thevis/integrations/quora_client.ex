defmodule Thevis.Integrations.QuoraClient do
  @moduledoc """
  Quora integration for profile/space (GEO community authority).

  No public API; profile URL from settings for authority tracking.
  Settings: %{"profile_url" => "..."} or %{"username" => "..."} or %{"space" => "..."}.
  """

  @base_url "https://www.quora.com"

  @doc """
  Returns profile or space URL. No API; consultant stores URL for citation tracking.
  Settings: %{"profile_url" => "..."}, %{"username" => "..."}, or %{"space" => "space-name"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"profile_url" => url}) when is_binary(url) and url != "" do
    {:ok, %{profile_url: url, source: "quora"}}
  end

  def fetch_profile(%{"username" => username}) when is_binary(username) and username != "" do
    {:ok,
     %{
       profile_url: "#{@base_url}/profile/#{URI.encode(username)}",
       username: username,
       source: "quora"
     }}
  end

  def fetch_profile(%{"space" => space}) when is_binary(space) and space != "" do
    slug = space |> String.downcase() |> String.replace(~r/\s+/, "-")
    {:ok, %{profile_url: "#{@base_url}/spaces/#{URI.encode(slug)}", space: slug, source: "quora"}}
  end

  def fetch_profile(_), do: {:error, :invalid_settings}
end

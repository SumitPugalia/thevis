defmodule Thevis.Integrations.ClutchClient do
  @moduledoc """
  Clutch.co integration for B2B agency/service profiles (GEO authority).

  No public API; profile URL and optional manual sync. Settings: %{"profile_url" => "..."} or %{"company_slug" => "..."}.
  """

  @base_url "https://clutch.co"

  @doc """
  Returns profile URL from settings. No API; consultant can store profile URL for authority tracking.
  Settings: %{"profile_url" => "https://clutch.co/profile/..."} or %{"company_slug" => "example-inc"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"profile_url" => url}) when is_binary(url) and url != "" do
    {:ok, %{profile_url: url, source: "clutch"}}
  end

  def fetch_profile(%{"company_slug" => slug}) when is_binary(slug) and slug != "" do
    {:ok,
     %{profile_url: "#{@base_url}/profile/#{URI.encode(slug)}", slug: slug, source: "clutch"}}
  end

  def fetch_profile(_), do: {:error, :invalid_settings}
end

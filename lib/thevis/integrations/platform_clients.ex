defmodule Thevis.Integrations.PlatformClients do
  @moduledoc """
  Maps platform_type (from PlatformSetting) to the integration client module.

  Use fetch_profile(platform_type, settings) to call the correct client.
  """

  @platform_to_client %{
    "g2" => Thevis.Integrations.G2Client,
    "capterra" => Thevis.Integrations.CapterraClient,
    "trustpilot" => Thevis.Integrations.TrustpilotClient,
    "google_business" => Thevis.Integrations.GoogleBusinessClient,
    "yelp" => Thevis.Integrations.YelpClient,
    "crunchbase" => Thevis.Integrations.CrunchbaseClient,
    "linkedin_company" => Thevis.Integrations.LinkedInCompanyClient,
    "product_hunt" => Thevis.Integrations.ProductHuntClient,
    "clutch" => Thevis.Integrations.ClutchClient,
    "alternativeto" => Thevis.Integrations.AlternativeToClient,
    "twitter" => Thevis.Integrations.TwitterClient,
    "facebook" => Thevis.Integrations.FacebookClient,
    "reddit" => Thevis.Integrations.RedditClient,
    "stack_overflow" => Thevis.Integrations.StackExchangeClient,
    "quora" => Thevis.Integrations.QuoraClient,
    "hacker_news" => Thevis.Integrations.HackerNewsClient
  }

  @doc """
  Fetches profile/stats from the platform using the given settings map.
  Returns {:ok, profile_map} or {:error, reason}.
  """
  @spec fetch_profile(String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(platform_type, settings) when is_map(settings) do
    case Map.get(@platform_to_client, platform_type) do
      nil -> {:error, :unsupported_platform}
      module -> module.fetch_profile(settings)
    end
  end

  def fetch_profile(_, _), do: {:error, :invalid_settings}

  @doc """
  Returns the client module for a platform type, or nil if unsupported.
  """
  @spec client_for(String.t()) :: module() | nil
  def client_for(platform_type), do: Map.get(@platform_to_client, platform_type)

  @doc """
  Returns all platform types that have a dedicated client (review, directory, social, community).
  """
  @spec supported_platforms() :: [String.t()]
  def supported_platforms do
    Map.keys(@platform_to_client)
  end
end

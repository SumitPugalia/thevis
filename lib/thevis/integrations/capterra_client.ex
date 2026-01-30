defmodule Thevis.Integrations.CapterraClient do
  @moduledoc """
  Capterra (Gartner Digital Markets) integration for software listings (GEO authority).

  Same family as G2; profile URLs for Capterra. Settings: %{"product_slug" => "..."} or %{"company_name" => "..."}.
  """

  @base_url "https://www.capterra.com"

  @doc """
  Returns profile URL for Capterra listing.
  Settings: %{"product_slug" => "slug"} or %{"company_name" => "Name"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"product_slug" => slug}) when is_binary(slug) and slug != "" do
    {:ok,
     %{
       profile_url: "#{@base_url}/p/#{URI.encode(slug)}",
       slug: slug,
       source: "capterra"
     }}
  end

  def fetch_profile(%{"company_name" => name}) when is_binary(name) and name != "" do
    slug = name |> String.downcase() |> String.replace(~r/\s+/, "-")
    fetch_profile(%{"product_slug" => slug})
  end

  def fetch_profile(_), do: {:error, :invalid_settings}
end

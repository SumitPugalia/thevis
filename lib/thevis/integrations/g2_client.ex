defmodule Thevis.Integrations.G2Client do
  @moduledoc """
  G2 (Gartner Digital Markets) integration for software reviews (GEO authority).

  G2 provides partner/API access for vendors. Config: api_key via G2_API_KEY if available.
  Settings map: %{"product_slug" => "..."} or %{"company_name" => "..."} for profile URL.

  Public profile URL: https://www.g2.com/products/{slug}/reviews
  """

  @base_url "https://www.g2.com"

  @doc """
  Returns profile URL and placeholder stats. Full API may require Gartner partnership.
  Settings: %{"product_slug" => "slug"} or %{"company_name" => "Name"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"product_slug" => slug}) when is_binary(slug) and slug != "" do
    {:ok,
     %{
       profile_url: "#{@base_url}/products/#{URI.encode(slug)}/reviews",
       slug: slug,
       source: "g2"
     }}
  end

  def fetch_profile(%{"company_name" => name}) when is_binary(name) and name != "" do
    slug = name |> String.downcase() |> String.replace(~r/\s+/, "-")
    fetch_profile(%{"product_slug" => slug})
  end

  def fetch_profile(_), do: {:error, :invalid_settings}
end

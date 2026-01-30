defmodule Thevis.Integrations.AlternativeToClient do
  @moduledoc """
  AlternativeTo integration for software/product listings (GEO authority).

  No official public API; profile URL from settings. Settings: %{"product_slug" => "..."} or %{"product_name" => "..."}.
  """

  @base_url "https://alternativeto.net"

  @doc """
  Returns profile URL for AlternativeTo product page.
  Settings: %{"product_slug" => "slug"} or %{"product_name" => "Name"}.
  """
  @spec fetch_profile(map()) :: {:ok, map()} | {:error, atom()}
  def fetch_profile(%{"product_slug" => slug}) when is_binary(slug) and slug != "" do
    {:ok,
     %{
       profile_url: "#{@base_url}/software/#{URI.encode(slug)}/",
       slug: slug,
       source: "alternativeto"
     }}
  end

  def fetch_profile(%{"product_name" => name}) when is_binary(name) and name != "" do
    slug = name |> String.downcase() |> String.replace(~r/\s+/, "-")
    fetch_profile(%{"product_slug" => slug})
  end

  def fetch_profile(_), do: {:error, :invalid_settings}
end

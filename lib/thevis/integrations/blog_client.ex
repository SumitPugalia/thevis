defmodule Thevis.Integrations.BlogClient do
  @moduledoc """
  Blog CMS client for publishing articles (supports WordPress, Contentful, etc.).
  """

  @doc """
  Publishes an article to a blog CMS.
  """
  def publish_article(title, content, metadata \\ %{}) do
    cms_type = get_cms_type()

    case cms_type do
      "wordpress" -> publish_to_wordpress(title, content, metadata)
      "contentful" -> publish_to_contentful(title, content, metadata)
      _ -> {:error, :unsupported_cms}
    end
  end

  defp publish_to_wordpress(title, content, metadata) do
    api_url = get_api_url()
    username = get_username()
    password = get_api_key()

    if api_url && username && password do
      # WordPress REST API endpoint
      url = "#{api_url}/wp-json/wp/v2/posts"

      body =
        Jason.encode!(%{
          title: title,
          content: content,
          status: Map.get(metadata, :status, "draft"),
          categories: Map.get(metadata, :categories, []),
          tags: Map.get(metadata, :tags, [])
        })

      # Basic Auth for WordPress
      auth = Base.encode64("#{username}:#{password}")

      headers = [
        {"Authorization", "Basic #{auth}"},
        {"Content-Type", "application/json"}
      ]

      case Thevis.HTTP.post(url, body: body, headers: headers) do
        {:ok, response} when is_map(response) ->
          {:ok, response["link"]}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :missing_credentials}
    end
  end

  defp publish_to_contentful(title, content, metadata) do
    token = get_api_key()
    space_id = get_contentful_space_id()
    environment_id = get_contentful_environment_id()
    content_type_id = get_contentful_content_type_id()
    locale = get_contentful_locale()

    if token && space_id && environment_id && content_type_id do
      base_url = get_contentful_base_url()
      url = "#{base_url}/spaces/#{space_id}/environments/#{environment_id}/entries"

      body_field_id = Map.get(metadata, :content_field_id, "body")

      body =
        Jason.encode!(%{
          "fields" => %{
            "title" => %{locale => title},
            body_field_id => %{locale => content}
          }
        })

      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/vnd.contentful.management.v1+json"},
        {"X-Contentful-Content-Type", content_type_id}
      ]

      case Thevis.HTTP.post(url, body: body, headers: headers) do
        {:ok, response} when is_map(response) ->
          entry_id = get_in(response, ["sys", "id"])
          {:ok, "https://app.contentful.com/spaces/#{space_id}/entries/#{entry_id}"}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :missing_credentials}
    end
  end

  defp get_contentful_space_id do
    Thevis.Integrations.get_config_value(__MODULE__, :contentful_space_id)
  end

  defp get_contentful_environment_id do
    Thevis.Integrations.get_config_value(__MODULE__, :contentful_environment_id, "master")
  end

  defp get_contentful_content_type_id do
    Thevis.Integrations.get_config_value(__MODULE__, :contentful_content_type_id, "blogPost")
  end

  defp get_contentful_locale do
    Thevis.Integrations.get_config_value(__MODULE__, :contentful_locale, "en-US")
  end

  defp get_contentful_base_url do
    Thevis.Integrations.get_config_value(
      __MODULE__,
      :contentful_base_url,
      "https://api.contentful.com"
    )
  end

  defp get_cms_type do
    Thevis.Integrations.get_config_value(__MODULE__, :cms_type, "wordpress")
  end

  defp get_api_url do
    Thevis.Integrations.get_config_value(__MODULE__, :api_url)
  end

  defp get_username do
    Thevis.Integrations.get_config_value(__MODULE__, :username)
  end

  defp get_api_key do
    Thevis.Integrations.get_config_value(__MODULE__, :api_key)
  end
end

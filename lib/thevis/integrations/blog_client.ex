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

      case Req.post(url, body: body, headers: headers) do
        {:ok, %{status: 201, body: response}} ->
          {:ok, response["link"]}

        {:ok, %{status: status, body: body}} ->
          {:error, {:api_error, status, body}}

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

      case Req.post(url, body: body, headers: headers) do
        {:ok, %{status: 201, body: response}} ->
          entry_id = get_in(response, ["sys", "id"])
          {:ok, "https://app.contentful.com/spaces/#{space_id}/entries/#{entry_id}"}

        {:ok, %{status: status, body: body_response}} ->
          {:error, {:api_error, status, body_response}}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :missing_credentials}
    end
  end

  defp get_contentful_space_id do
    get_config_value(:contentful_space_id)
  end

  defp get_contentful_environment_id do
    get_config_value(:contentful_environment_id) || "master"
  end

  defp get_contentful_content_type_id do
    get_config_value(:contentful_content_type_id) || "blogPost"
  end

  defp get_contentful_locale do
    get_config_value(:contentful_locale) || "en-US"
  end

  defp get_contentful_base_url do
    get_config_value(:contentful_base_url) || "https://api.contentful.com"
  end

  defp get_config_value(key) do
    config = Application.get_env(:thevis, __MODULE__)
    if config, do: resolve_config_value(Keyword.get(config, key)), else: nil
  end

  defp resolve_config_value({System, :get_env, [key]}), do: System.get_env(key)

  defp resolve_config_value({System, :get_env, [key, default]}),
    do: System.get_env(key) || default

  defp resolve_config_value(val) when is_binary(val), do: val
  defp resolve_config_value(_), do: nil

  defp get_cms_type do
    config = Application.get_env(:thevis, __MODULE__)

    if config do
      cms_type = Keyword.get(config, :cms_type, "wordpress")

      case cms_type do
        {System, :get_env, [key, default]} -> System.get_env(key) || default
        type when is_binary(type) -> type
        _ -> "wordpress"
      end
    else
      "wordpress"
    end
  end

  defp get_api_url do
    config = Application.get_env(:thevis, __MODULE__)

    if config do
      api_url = Keyword.get(config, :api_url)

      case api_url do
        {System, :get_env, [key]} -> System.get_env(key)
        url when is_binary(url) -> url
        _ -> nil
      end
    else
      nil
    end
  end

  defp get_username do
    config = Application.get_env(:thevis, __MODULE__)

    if config do
      username = Keyword.get(config, :username)

      case username do
        {System, :get_env, [key]} -> System.get_env(key)
        username_value when is_binary(username_value) -> username_value
        _ -> nil
      end
    else
      nil
    end
  end

  defp get_api_key do
    config = Application.get_env(:thevis, __MODULE__)

    if config do
      api_key = Keyword.get(config, :api_key)

      case api_key do
        {System, :get_env, [key]} -> System.get_env(key)
        key_value when is_binary(key_value) -> key_value
        _ -> nil
      end
    else
      nil
    end
  end
end

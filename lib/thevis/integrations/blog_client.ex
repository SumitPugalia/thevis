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

  defp publish_to_contentful(_title, _content, _metadata) do
    # Contentful implementation would go here
    {:error, :not_implemented}
  end

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

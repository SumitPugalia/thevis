defmodule Thevis.Integrations.MediumClient do
  @moduledoc """
  Medium API client for publishing articles.
  """

  @api_url Application.compile_env(:thevis, [__MODULE__, :api_url], "https://api.medium.com/v1")

  @doc """
  Publishes an article to Medium.
  """
  def publish_article(title, content, tags \\ [], publish_status \\ "draft") do
    token = get_api_token()

    # First, get user info
    case get_user(token) do
      {:ok, user} ->
        create_post(user["id"], title, content, tags, publish_status, token)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_user(token) do
    url = "#{@api_url}/me"
    headers = [{"Authorization", "Bearer #{token}"}, {"Content-Type", "application/json"}]

    case Thevis.HTTP.get(url, headers: headers) do
      {:ok, response} when is_map(response) ->
        {:ok, response["data"]}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_post(user_id, title, content, tags, publish_status, token) do
    url = "#{@api_url}/users/#{user_id}/posts"

    body =
      Jason.encode!(%{
        title: title,
        contentFormat: "markdown",
        content: content,
        tags: tags,
        publishStatus: publish_status
      })

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ]

    case Thevis.HTTP.post(url, body: body, headers: headers) do
      {:ok, response} when is_map(response) ->
        {:ok, get_in(response, ["data", "url"])}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_api_token do
    Thevis.Integrations.get_api_token(__MODULE__)
  end
end

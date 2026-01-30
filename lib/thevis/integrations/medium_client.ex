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

    case Req.get(url, headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response["data"]}

      {:ok, %{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

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

    case Req.post(url, body: body, headers: headers) do
      {:ok, %{status: 201, body: response}} ->
        {:ok, response["data"]["url"]}

      {:ok, %{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_api_token do
    config = Application.get_env(:thevis, __MODULE__)

    if config do
      api_token = Keyword.get(config, :api_token)

      case api_token do
        {System, :get_env, [key]} -> System.get_env(key)
        token when is_binary(token) -> token
        _ -> nil
      end
    else
      nil
    end
  end
end

defmodule Thevis.Integrations.GitHubClient do
  @moduledoc """
  GitHub API client for repository operations.
  """

  @api_url Application.compile_env(:thevis, [__MODULE__, :api_url], "https://api.github.com")

  @doc """
  Updates or creates a README file in a GitHub repository.
  """
  def update_readme(repo_owner, repo_name, content, branch \\ "main") do
    file_path = "README.md"

    # Get current file SHA if exists
    case get_file_sha(repo_owner, repo_name, file_path, branch) do
      {:ok, sha} ->
        update_file(repo_owner, repo_name, file_path, content, sha, branch)

      {:error, :not_found} ->
        create_file(repo_owner, repo_name, file_path, content, branch)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Creates a new file in a GitHub repository.
  """
  def create_file(repo_owner, repo_name, file_path, content, branch \\ "main") do
    token = get_api_token()

    url = "#{@api_url}/repos/#{repo_owner}/#{repo_name}/contents/#{file_path}"

    body =
      Jason.encode!(%{
        message: "Update #{file_path} via thevis automation",
        content: Base.encode64(content),
        branch: branch
      })

    headers = [
      {"Authorization", "token #{token}"},
      {"Accept", "application/vnd.github.v3+json"},
      {"Content-Type", "application/json"}
    ]

    case Req.post(url, body: body, headers: headers) do
      {:ok, %{status: 201, body: response}} ->
        {:ok, response["content"]["html_url"]}

      {:ok, %{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Updates an existing file in a GitHub repository.
  """
  def update_file(repo_owner, repo_name, file_path, content, sha, branch \\ "main") do
    token = get_api_token()

    url = "#{@api_url}/repos/#{repo_owner}/#{repo_name}/contents/#{file_path}"

    body =
      Jason.encode!(%{
        message: "Update #{file_path} via thevis automation",
        content: Base.encode64(content),
        sha: sha,
        branch: branch
      })

    headers = [
      {"Authorization", "token #{token}"},
      {"Accept", "application/vnd.github.v3+json"},
      {"Content-Type", "application/json"}
    ]

    case Req.put(url, body: body, headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response["content"]["html_url"]}

      {:ok, %{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_file_sha(repo_owner, repo_name, file_path, branch) do
    token = get_api_token()
    url = "#{@api_url}/repos/#{repo_owner}/#{repo_name}/contents/#{file_path}?ref=#{branch}"

    headers = [
      {"Authorization", "token #{token}"},
      {"Accept", "application/vnd.github.v3+json"}
    ]

    case Req.get(url, headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response["sha"]}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

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

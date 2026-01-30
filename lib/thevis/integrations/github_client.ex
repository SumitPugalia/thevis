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

  @doc """
  Fetches README content for a repository (decoded as UTF-8 text).
  """
  def get_readme(repo_owner, repo_name) do
    token = get_api_token()

    url = "#{@api_url}/repos/#{repo_owner}/#{repo_name}/readme"

    headers = maybe_add_auth([{"Accept", "application/vnd.github.v3+json"}], token)

    case Req.get(url, headers: headers) do
      {:ok, %{status: 200, body: %{"content" => encoded, "encoding" => "base64"}}} ->
        {:ok, Base.decode64!(encoded)}

      {:ok, %{status: 200, body: %{"content" => encoded}}} ->
        {:ok, Base.decode64!(encoded)}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Searches GitHub repositories by query. Returns a list of repo maps with :full_name, :html_url, etc.
  """
  def search_repositories(query, opts \\ []) do
    token = get_api_token()
    per_page = Keyword.get(opts, :per_page, 5)

    url = "#{@api_url}/search/repositories"
    params = [q: query, per_page: per_page, sort: "stars"]

    headers = maybe_add_auth([{"Accept", "application/vnd.github.v3+json"}], token)

    case Req.get(url, params: params, headers: headers) do
      {:ok, %{status: 200, body: %{"items" => items}}} ->
        repos =
          Enum.map(items, fn item ->
            %{
              full_name: item["full_name"],
              html_url: item["html_url"],
              description: item["description"],
              name: item["name"],
              owner: item["owner"]["login"]
            }
          end)

        {:ok, repos}

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
    Thevis.Integrations.get_api_token(__MODULE__)
  end

  defp maybe_add_auth(headers, nil), do: headers
  defp maybe_add_auth(headers, token), do: [{"Authorization", "token #{token}"} | headers]
end

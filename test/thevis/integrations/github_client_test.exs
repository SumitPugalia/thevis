defmodule Thevis.Integrations.GitHubClientTest do
  use ExUnit.Case, async: true

  alias Thevis.Integrations.GitHubClient

  describe "update_readme/4" do
    test "returns error when API token is not configured" do
      # This will fail gracefully when token is nil
      result = GitHubClient.update_readme("owner", "repo", "content", "main")
      assert match?({:error, _}, result)
    end
  end

  describe "create_file/5" do
    test "returns error when API token is not configured" do
      result = GitHubClient.create_file("owner", "repo", "README.md", "content", "main")
      assert match?({:error, _}, result)
    end
  end

  describe "update_file/6" do
    test "returns error when API token is not configured" do
      result = GitHubClient.update_file("owner", "repo", "README.md", "content", "sha123", "main")
      assert match?({:error, _}, result)
    end
  end
end

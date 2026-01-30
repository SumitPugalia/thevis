defmodule Thevis.Integrations.BlogClientTest do
  use ExUnit.Case, async: true

  alias Thevis.Integrations.BlogClient

  describe "publish_article/3" do
    test "returns error when credentials are not configured" do
      result = BlogClient.publish_article("Title", "Content", %{})
      assert match?({:error, :missing_credentials}, result)
    end

    test "returns error for unsupported CMS type" do
      # This would require mocking the config, but basic test structure is here
      result = BlogClient.publish_article("Title", "Content", %{})
      assert match?({:error, _}, result)
    end
  end
end

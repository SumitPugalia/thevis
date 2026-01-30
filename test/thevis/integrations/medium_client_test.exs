defmodule Thevis.Integrations.MediumClientTest do
  use ExUnit.Case, async: true

  alias Thevis.Integrations.MediumClient

  describe "publish_article/4" do
    test "returns error when API token is not configured" do
      result = MediumClient.publish_article("Title", "Content", [], "draft")
      assert match?({:error, _}, result)
    end
  end
end

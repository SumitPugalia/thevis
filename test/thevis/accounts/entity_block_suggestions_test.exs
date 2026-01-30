defmodule Thevis.Accounts.EntityBlockSuggestionsTest do
  use Thevis.DataCase
  import Mox

  alias Thevis.Accounts.EntityBlockSuggestions
  alias Thevis.AI.MockAdapter

  setup :verify_on_exit!

  describe "suggest_for_company/1" do
    setup do
      Application.put_env(:thevis, Thevis.AI, adapter: MockAdapter)
      :ok
    end

    test "returns suggested entity block when LLM returns valid JSON" do
      company =
        insert(:company, name: "Acme", industry: "Technology", description: "We build tools.")

      expect(MockAdapter, :chat_completion, fn _messages, _opts ->
        content = """
        {"one_line_definition": "Acme helps brands optimize for AI search.", "problem_solved": "Brands are invisible in AI answers.", "key_concepts": "GEO, AI visibility, search"}
        """

        {:ok,
         %{
           "choices" => [
             %{"message" => %{"content" => content}}
           ]
         }}
      end)

      assert {:ok, result} = EntityBlockSuggestions.suggest_for_company(company)
      assert result["one_line_definition"] == "Acme helps brands optimize for AI search."
      assert result["problem_solved"] == "Brands are invisible in AI answers."
      assert result["key_concepts"] == "GEO, AI visibility, search"
    end

    test "returns error when AI returns error" do
      company = insert(:company)

      expect(MockAdapter, :chat_completion, fn _messages, _opts ->
        {:error, :timeout}
      end)

      assert {:error, :ai_error} = EntityBlockSuggestions.suggest_for_company(company)
    end
  end
end

defmodule Thevis.Geo.RecallTestTest do
  use Thevis.DataCase
  import Mox

  alias Thevis.Geo.RecallTest
  alias Thevis.Products.Product

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "generate_test_prompts/1" do
    test "generates prompts for all categories" do
      product = %Product{
        name: "Test Product",
        category: "skincare",
        product_type: :cosmetic
      }

      prompts = RecallTest.generate_test_prompts(product)

      assert length(prompts) == 6
      assert Enum.all?(prompts, &Map.has_key?(&1, :category))
      assert Enum.all?(prompts, &Map.has_key?(&1, :prompt))

      categories = Enum.map(prompts, & &1.category)
      assert "product_search" in categories
      assert "category_search" in categories
      assert "use_case" in categories
      assert "comparison" in categories
      assert "recommendation" in categories
      assert "general" in categories
    end

    test "includes product category in prompts" do
      product = %Product{
        name: "Glow Serum",
        category: "skincare",
        product_type: :cosmetic
      }

      prompts = RecallTest.generate_test_prompts(product)

      product_search_prompt =
        Enum.find(prompts, &(&1.category == "product_search"))

      assert product_search_prompt.prompt =~ "skincare"
    end
  end

  describe "execute_recall_test/2" do
    test "detects when product is mentioned in response" do
      product = %Product{name: "Glow Serum", category: "skincare", product_type: :cosmetic}

      Thevis.AI.MockAdapter
      |> expect(:chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" =>
                   "Some great skincare products include Glow Serum, which is excellent for hydration."
               }
             }
           ]
         }}
      end)

      {:ok, result} =
        RecallTest.execute_recall_test("What are the best skincare products?", product)

      assert result.mentioned == true
      assert is_integer(result.mention_rank)
      assert result.mention_rank > 0
      assert result.response_text =~ "Glow Serum"
    end

    test "detects when product is not mentioned" do
      product = %Product{name: "Glow Serum", category: "skincare", product_type: :cosmetic}

      Thevis.AI.MockAdapter
      |> expect(:chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" =>
                   "Some great skincare products include Vitamin C Serum and Retinol Cream."
               }
             }
           ]
         }}
      end)

      {:ok, result} =
        RecallTest.execute_recall_test("What are the best skincare products?", product)

      assert result.mentioned == false
      assert result.mention_rank == nil
    end

    test "handles AI adapter errors" do
      product = %Product{name: "Glow Serum", category: "skincare", product_type: :cosmetic}

      Thevis.AI.MockAdapter
      |> expect(:chat_completion, fn _messages, _opts ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} =
               RecallTest.execute_recall_test("What are the best products?", product)
    end
  end

  describe "test_recall/2" do
    test "executes multiple recall tests" do
      product = %Product{name: "Glow Serum", category: "skincare", product_type: :cosmetic}

      # Mock multiple calls (one for each prompt category we're testing)
      Thevis.AI.MockAdapter
      |> expect(:chat_completion, 2, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "Glow Serum is a great product."
               }
             }
           ]
         }}
      end)

      {:ok, results} = RecallTest.test_recall(product, ["product_search", "category_search"])

      assert length(results) == 2

      assert Enum.all?(results, fn
               {:ok, result} -> Map.has_key?(result, :mentioned)
               {:error, _} -> true
             end)
    end

    test "filters prompts by category" do
      product = %Product{name: "Test Product", category: "skincare", product_type: :cosmetic}

      Thevis.AI.MockAdapter
      |> expect(:chat_completion, 1, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "Test response"
               }
             }
           ]
         }}
      end)

      {:ok, results} = RecallTest.test_recall(product, ["product_search"])

      assert length(results) == 1
    end
  end
end

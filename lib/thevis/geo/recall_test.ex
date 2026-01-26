defmodule Thevis.Geo.RecallTest do
  @moduledoc """
  Recall Test Engine for measuring unprompted AI visibility.

  This module generates and executes recall tests to measure how often
  a product is mentioned in AI responses to various prompts without
  explicitly asking about the product.
  """

  alias Thevis.AI
  alias Thevis.Products.Product

  @prompt_categories [
    "product_search",
    "category_search",
    "use_case",
    "comparison",
    "recommendation",
    "general"
  ]

  @doc """
  Generates recall test prompts for a product across different categories.

  ## Examples

      iex> generate_test_prompts(product)
      [
        %{category: "product_search", prompt: "What are the best skincare products?"},
        ...
      ]

  """
  def generate_test_prompts(%Product{} = product) do
    category = product.category || "products"
    product_type = to_string(product.product_type)

    [
      %{
        category: "product_search",
        prompt: "What are the best #{category} available?"
      },
      %{
        category: "category_search",
        prompt: "Recommend some #{category} in the #{product_type} category"
      },
      %{
        category: "use_case",
        prompt: "I need a #{category} for [use case]. What should I consider?"
      },
      %{
        category: "comparison",
        prompt: "Compare different #{category} options"
      },
      %{
        category: "recommendation",
        prompt: "What #{category} would you recommend?"
      },
      %{
        category: "general",
        prompt: "Tell me about #{category} and what's available"
      }
    ]
  end

  @doc """
  Executes a single recall test prompt and checks if the product is mentioned.

  ## Examples

      iex> execute_recall_test("What are the best skincare products?", product)
      {:ok, %{mentioned: true, mention_rank: 3, response_text: "..."}}

  """
  def execute_recall_test(prompt_text, %Product{} = product, opts \\ []) do
    adapter_opts = Keyword.get(opts, :adapter_opts, [])

    messages = [
      %{
        role: "user",
        content: prompt_text
      }
    ]

    case AI.chat_completion(messages, adapter_opts) do
      {:ok, response} ->
        analyze_response(response, product, prompt_text)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Executes multiple recall tests in parallel.

  ## Examples

      iex> test_recall(product, ["product_search", "category_search"])
      {:ok, [%{category: "product_search", mentioned: true, ...}, ...]}

  """
  def test_recall(%Product{} = product, categories \\ @prompt_categories, opts \\ []) do
    prompts = generate_test_prompts(product)
    filtered_prompts = Enum.filter(prompts, &(&1.category in categories))

    results =
      filtered_prompts
      |> Enum.map(fn %{category: category, prompt: prompt} ->
        case execute_recall_test(prompt, product, opts) do
          {:ok, result} ->
            {:ok, Map.merge(result, %{category: category, prompt: prompt})}

          {:error, reason} ->
            {:error, %{category: category, prompt: prompt, error: reason}}
        end
      end)

    {:ok, results}
  end

  defp analyze_response(response, %Product{} = product, _prompt_text) do
    response_text = extract_response_text(response)
    product_name = String.downcase(product.name)
    response_lower = String.downcase(response_text)

    mentioned = String.contains?(response_lower, product_name)
    mention_rank = if mentioned, do: find_mention_rank(response_text, product_name), else: nil

    {:ok,
     %{
       mentioned: mentioned,
       mention_rank: mention_rank,
       response_text: response_text,
       raw_response: response
     }}
  end

  defp extract_response_text(response) when is_map(response) do
    case response do
      %{"choices" => [%{"message" => %{"content" => content}} | _]} ->
        content

      %{"content" => content} ->
        content

      _ ->
        inspect(response)
    end
  end

  defp extract_response_text(response) when is_binary(response), do: response
  defp extract_response_text(response), do: inspect(response)

  defp find_mention_rank(response_text, product_name) do
    sentences = String.split(response_text, ~r/[.!?]+/, trim: true)
    product_name_words = String.split(product_name, " ", trim: true)

    Enum.find_index(sentences, fn sentence ->
      sentence_lower = String.downcase(sentence)
      Enum.any?(product_name_words, &String.contains?(sentence_lower, &1))
    end)
    |> case do
      nil -> nil
      index -> index + 1
    end
  end
end

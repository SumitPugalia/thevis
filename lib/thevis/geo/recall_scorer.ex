defmodule Thevis.Geo.RecallScorer do
  @moduledoc """
  Recall Scorer for calculating recall metrics from test results.

  This module calculates recall percentage, first mention rank,
  and competitor comparisons.
  """

  @doc """
  Calculates recall percentage from test results.

  Recall percentage is the percentage of prompts where the product was mentioned.

  ## Examples

      iex> calculate_recall_percentage([%{mentioned: true}, %{mentioned: false}, %{mentioned: true}])
      66.67

  """
  def calculate_recall_percentage(results) when is_list(results) do
    results
    |> Enum.filter(&is_valid_result/1)
    |> then(fn valid_results ->
      if Enum.empty?(valid_results) do
        0.0
      else
        mentioned_count =
          valid_results
          |> Enum.count(&(&1.mentioned == true))

        mentioned_count / length(valid_results) * 100
      end
    end)
  end

  def calculate_recall_percentage(_), do: 0.0

  @doc """
  Calculates the average first mention rank.

  Only considers results where the product was mentioned.

  ## Examples

      iex> calculate_first_mention_rank([%{mentioned: true, mention_rank: 1}, %{mentioned: true, mention_rank: 3}])
      2.0

  """
  def calculate_first_mention_rank(results) when is_list(results) do
    results
    |> Enum.filter(&(&1.mentioned == true && is_integer(&1.mention_rank)))
    |> then(fn mentioned_results ->
      if Enum.empty?(mentioned_results) do
        nil
      else
        mentioned_results
        |> Enum.map(& &1.mention_rank)
        |> Enum.sum()
        |> then(&(&1 / length(mentioned_results)))
      end
    end)
  end

  def calculate_first_mention_rank(_), do: nil

  @doc """
  Compares recall results with competitors.

  Returns comparison metrics showing how the product performs
  relative to competitors.

  ## Examples

      iex> compare_with_competitors(product_results, competitor_results)
      %{
        product_recall: 75.0,
        competitor_recall: 60.0,
        advantage: 15.0,
        displacement_rate: 0.3
      }

  """
  def compare_with_competitors(product_results, competitor_results)
      when is_list(competitor_results) do
    product_recall = calculate_recall_percentage(product_results)
    competitor_recall = calculate_recall_percentage(competitor_results)

    advantage = product_recall - competitor_recall

    # Calculate displacement rate (how often product is mentioned instead of competitor)
    displacement_rate = calculate_displacement_rate(product_results, competitor_results)

    %{
      product_recall: product_recall,
      competitor_recall: competitor_recall,
      advantage: advantage,
      displacement_rate: displacement_rate
    }
  end

  def compare_with_competitors(product_results, _),
    do: %{
      product_recall: calculate_recall_percentage(product_results),
      competitor_recall: 0.0,
      advantage: calculate_recall_percentage(product_results),
      displacement_rate: 0.0
    }

  defp is_valid_result(%{mentioned: _mentioned}), do: true
  defp is_valid_result(_), do: false

  defp calculate_displacement_rate(product_results, competitor_results) do
    # Count how many prompts where product was mentioned but competitor wasn't
    product_mentioned = Enum.count(product_results, &(&1.mentioned == true))
    competitor_mentioned = Enum.count(competitor_results, &(&1.mentioned == true))

    if competitor_mentioned > 0 do
      # Simple displacement: when product is mentioned more often
      max(0, (product_mentioned - competitor_mentioned) / length(product_results))
    else
      0.0
    end
  end
end

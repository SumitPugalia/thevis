defmodule Thevis.Geo.RecallScorerTest do
  use Thevis.DataCase

  alias Thevis.Geo.RecallScorer

  describe "calculate_recall_percentage/1" do
    test "calculates percentage when all mentioned" do
      results = [
        %{mentioned: true},
        %{mentioned: true},
        %{mentioned: true}
      ]

      assert RecallScorer.calculate_recall_percentage(results) == 100.0
    end

    test "calculates percentage when none mentioned" do
      results = [
        %{mentioned: false},
        %{mentioned: false},
        %{mentioned: false}
      ]

      assert RecallScorer.calculate_recall_percentage(results) == 0.0
    end

    test "calculates percentage for mixed results" do
      results = [
        %{mentioned: true},
        %{mentioned: false},
        %{mentioned: true},
        %{mentioned: false}
      ]

      assert RecallScorer.calculate_recall_percentage(results) == 50.0
    end

    test "handles empty list" do
      assert RecallScorer.calculate_recall_percentage([]) == 0.0
    end

    test "handles invalid input" do
      assert RecallScorer.calculate_recall_percentage(nil) == 0.0
    end
  end

  describe "calculate_first_mention_rank/1" do
    test "calculates average rank when mentioned" do
      results = [
        %{mentioned: true, mention_rank: 1},
        %{mentioned: true, mention_rank: 3},
        %{mentioned: true, mention_rank: 2}
      ]

      assert RecallScorer.calculate_first_mention_rank(results) == 2.0
    end

    test "returns nil when not mentioned" do
      results = [
        %{mentioned: false},
        %{mentioned: false}
      ]

      assert RecallScorer.calculate_first_mention_rank(results) == nil
    end

    test "handles mixed results" do
      results = [
        %{mentioned: true, mention_rank: 1},
        %{mentioned: false},
        %{mentioned: true, mention_rank: 5}
      ]

      assert RecallScorer.calculate_first_mention_rank(results) == 3.0
    end

    test "handles empty list" do
      assert RecallScorer.calculate_first_mention_rank([]) == nil
    end
  end

  describe "compare_with_competitors/2" do
    test "calculates comparison metrics" do
      product_results = [
        %{mentioned: true},
        %{mentioned: true},
        %{mentioned: false}
      ]

      competitor_results = [
        %{mentioned: true},
        %{mentioned: false},
        %{mentioned: false}
      ]

      comparison = RecallScorer.compare_with_competitors(product_results, competitor_results)

      assert_in_delta comparison.product_recall, 66.67, 0.1
      assert_in_delta comparison.competitor_recall, 33.33, 0.1
      assert comparison.advantage > 0
      assert is_float(comparison.displacement_rate)
    end

    test "handles empty competitor results" do
      product_results = [
        %{mentioned: true},
        %{mentioned: false}
      ]

      comparison = RecallScorer.compare_with_competitors(product_results, [])

      assert comparison.product_recall == 50.0
      assert comparison.competitor_recall == 0.0
      assert comparison.advantage == 50.0
    end

    test "handles nil competitor results" do
      product_results = [
        %{mentioned: true}
      ]

      comparison = RecallScorer.compare_with_competitors(product_results, nil)

      assert comparison.product_recall == 100.0
      assert comparison.competitor_recall == 0.0
    end
  end
end

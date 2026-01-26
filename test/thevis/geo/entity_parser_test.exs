defmodule Thevis.Geo.EntityParserTest do
  use ExUnit.Case, async: true

  alias Thevis.Geo.EntityParser

  describe "parse_entity_response/1" do
    test "parses valid OpenAI response" do
      response = %{
        "choices" => [
          %{
            "message" => %{
              "content" => "Glow Serum is a premium skincare product."
            }
          }
        ]
      }

      parsed = EntityParser.parse_entity_response(response)

      assert parsed.description == "Glow Serum is a premium skincare product."
      assert is_float(parsed.confidence)
      assert parsed.confidence > 0.0
    end

    test "handles empty choices" do
      response = %{"choices" => []}

      parsed = EntityParser.parse_entity_response(response)

      assert parsed.description == ""
      assert parsed.confidence == 0.0
    end

    test "handles invalid response structure" do
      response = %{"invalid" => "structure"}

      parsed = EntityParser.parse_entity_response(response)

      assert parsed.description == ""
      assert parsed.confidence == 0.0
    end
  end

  describe "extract_description/1" do
    test "extracts description from parsed response" do
      parsed = %{description: "Some description", confidence: 0.9}
      assert EntityParser.extract_description(parsed) == "Some description"
    end

    test "returns empty string for invalid input" do
      assert EntityParser.extract_description(%{}) == ""
    end
  end

  describe "calculate_confidence/1" do
    test "returns 0.0 for 'don't know' responses" do
      assert EntityParser.calculate_confidence("I don't know about this product") == 0.0
      assert EntityParser.calculate_confidence("I am not familiar with this") == 0.0
      assert EntityParser.calculate_confidence("No information available") == 0.0
    end

    test "returns higher confidence for detailed descriptions" do
      detailed = String.duplicate("This is a detailed description. ", 20)
      confidence = EntityParser.calculate_confidence(detailed)

      assert confidence > 0.5
      assert confidence <= 1.0
    end

    test "returns base confidence for short descriptions" do
      short = "This is a product."
      confidence = EntityParser.calculate_confidence(short)

      assert confidence >= 0.5
      assert confidence < 0.8
    end
  end
end

defmodule Thevis.Geo.EntityParser do
  @moduledoc """
  Parses AI responses to extract entity information.

  This module extracts structured data from AI responses, including
  descriptions and confidence scores.
  """

  @doc """
  Parses an entity response from the AI.

  ## Examples

      iex> parse_entity_response(%{"choices" => [%{"message" => %{"content" => "Glow Serum is a skincare product..."}}]})
      %{description: "Glow Serum is a skincare product...", confidence: 0.9}

  """
  def parse_entity_response(%{"choices" => [%{"message" => %{"content" => content}} | _]}) do
    description = String.trim(content)
    confidence = calculate_confidence(description)

    %{
      description: description,
      confidence: confidence
    }
  end

  def parse_entity_response(%{"choices" => []}) do
    %{
      description: "",
      confidence: 0.0
    }
  end

  def parse_entity_response(_response) do
    %{
      description: "",
      confidence: 0.0
    }
  end

  @doc """
  Extracts the description from a parsed response.

  ## Examples

      iex> extract_description(%{description: "Some description", confidence: 0.9})
      "Some description"

  """
  def extract_description(%{description: description}), do: description
  def extract_description(_), do: ""

  @doc """
  Calculates confidence score based on response content.

  Confidence is based on:
  - Explicit "I don't know" statements → 0.0
  - Detailed descriptions → higher confidence
  - Length and specificity → higher confidence

  ## Examples

      iex> calculate_confidence("I don't know about this product")
      0.0

      iex> calculate_confidence("Glow Serum is a premium skincare product...")
      0.85

  """
  def calculate_confidence(description) when is_binary(description) do
    description_lower = String.downcase(description)

    # Check for explicit "don't know" patterns
    dont_know_patterns = [
      "i don't know",
      "i do not know",
      "i'm not familiar",
      "i am not familiar",
      "i haven't heard",
      "i have not heard",
      "no information",
      "unable to find"
    ]

    has_dont_know =
      Enum.any?(dont_know_patterns, fn pattern ->
        String.contains?(description_lower, pattern)
      end)

    if has_dont_know do
      0.0
    else
      # Calculate confidence based on length and detail
      base_confidence = 0.5
      length_bonus = min(String.length(description) / 500.0, 0.3)
      detail_bonus = if String.length(description) > 100, do: 0.2, else: 0.0

      min(base_confidence + length_bonus + detail_bonus, 1.0)
    end
  end

  def calculate_confidence(_), do: 0.0
end

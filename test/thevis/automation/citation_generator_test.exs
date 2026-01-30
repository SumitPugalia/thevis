defmodule Thevis.Automation.CitationGeneratorTest do
  use ExUnit.Case, async: true

  alias Thevis.Automation.CitationGenerator
  alias Thevis.Projects.Project

  describe "generate_citations/2" do
    test "generates citations for a project" do
      project = %Project{
        id: "test-id",
        name: "Test Product"
      }

      {:ok, citations} = CitationGenerator.generate_citations(project, :academic)

      assert length(citations) == 1
      citation = List.first(citations)
      assert citation.type == :academic
      assert citation.title == "Test Product"
      assert is_list(citation.authors)
    end

    test "uses defaults when project settings are missing" do
      project = %Project{
        id: "test-id",
        name: "Test Product"
      }

      {:ok, citations} = CitationGenerator.generate_citations(project, :academic)

      assert length(citations) == 1
      citation = List.first(citations)
      assert citation.authors == ["thevis.ai"]
    end
  end

  describe "format_citations/2" do
    test "formats citations in APA style" do
      citation = %{
        type: :academic,
        title: "Test Product",
        authors: ["John Doe"],
        year: 2024,
        url: "https://example.com",
        source: "thevis.ai"
      }

      [formatted] = CitationGenerator.format_citations([citation], :apa)
      assert String.contains?(formatted, "John Doe")
      assert String.contains?(formatted, "Test Product")
      assert String.contains?(formatted, "2024")
    end

    test "formats citations in MLA style" do
      citation = %{
        type: :academic,
        title: "Test Product",
        authors: ["John Doe"],
        year: 2024,
        url: "https://example.com",
        source: "thevis.ai"
      }

      [formatted] = CitationGenerator.format_citations([citation], :mla)
      assert String.contains?(formatted, "John Doe")
      assert String.contains?(formatted, "Test Product")
    end

    test "formats citations in Chicago style" do
      citation = %{
        type: :academic,
        title: "Test Product",
        authors: ["John Doe"],
        year: 2024,
        url: "https://example.com",
        source: "thevis.ai"
      }

      [formatted] = CitationGenerator.format_citations([citation], :chicago)
      assert String.contains?(formatted, "John Doe")
      assert String.contains?(formatted, "Test Product")
    end
  end

  describe "generate_citation_text/2" do
    test "generates citation text for a project" do
      project = %Project{
        id: "test-id",
        name: "Test Product"
      }

      citation_text = CitationGenerator.generate_citation_text(project, :apa)
      assert is_binary(citation_text)
      assert String.length(citation_text) > 0
    end
  end
end

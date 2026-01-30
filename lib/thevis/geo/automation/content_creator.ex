defmodule Thevis.Geo.Automation.ContentCreator do
  @moduledoc """
  Content Creator Engine for generating content from narratives.
  """

  alias Thevis.Projects.Project
  alias Thevis.Strategy.NarrativeBuilder

  @doc """
  Generates content for a project based on narrative and content type.
  """
  def generate_content(%Project{} = project, content_type, narrative \\ nil) do
    narrative = narrative || NarrativeBuilder.get_active_narrative(project)

    if narrative do
      content = generate_content_by_type(narrative, content_type)
      {:ok, content}
    else
      {:error, :narrative_not_found}
    end
  end

  @doc """
  Optimizes content for AI training signals.
  """
  def optimize_for_ai(content, _company) do
    # Simple optimization - can be enhanced with AI
    optimized_content = add_ai_optimizations(content)
    score = calculate_ai_score(optimized_content)

    {:ok, optimized_content, score}
  end

  @doc """
  Creates a wiki page for a project from a narrative.
  """
  def create_wiki_page(%Project{} = project, _narrative, platform) do
    alias Thevis.Geo.Automation.WikiManager

    WikiManager.create_wiki_page(project, platform, :product)
  end

  @doc """
  Creates a Wikipedia page for a project.
  """
  def create_wikipedia_page(%Project{} = project, _narrative) do
    create_wiki_page(project, nil, "Wikipedia")
  end

  @doc """
  Creates a company wiki page for a project.
  """
  def create_company_wiki_page(%Project{} = project, _narrative) do
    create_wiki_page(project, nil, "Company Wiki")
  end

  @doc """
  Creates a GitHub README for a project.
  """
  def create_github_readme(%Project{} = project, narrative) do
    narrative = narrative || NarrativeBuilder.get_active_narrative(project)

    if narrative do
      content = generate_github_readme(narrative, project)
      {:ok, content}
    else
      {:error, :narrative_not_found}
    end
  end

  @doc """
  Creates a blog post for a project.
  """
  def create_blog_post(%Project{} = project, topic, narrative) do
    narrative = narrative || NarrativeBuilder.get_active_narrative(project)

    if narrative do
      content = generate_blog_post(narrative, topic)
      {:ok, content}
    else
      {:error, :narrative_not_found}
    end
  end

  @doc """
  Creates a documentation page for a project.
  """
  def create_documentation_page(%Project{} = project, section, narrative) do
    narrative = narrative || NarrativeBuilder.get_active_narrative(project)

    if narrative do
      content = generate_documentation(narrative, section)
      {:ok, content}
    else
      {:error, :narrative_not_found}
    end
  end

  defp generate_content_by_type(narrative, :blog_post) do
    """
    # #{narrative.content |> String.split("\n") |> List.first() |> String.trim()}

    #{narrative.content}

    ## Key Points
    - Point 1
    - Point 2
    - Point 3
    """
  end

  defp generate_content_by_type(narrative, :github_readme) do
    """
    # #{narrative.content |> String.split("\n") |> List.first() |> String.trim()}

    #{narrative.content}

    ## Installation
    [Installation instructions]

    ## Usage
    [Usage examples]

    ## Contributing
    [Contributing guidelines]
    """
  end

  defp generate_content_by_type(narrative, :documentation) do
    """
    # Documentation

    #{narrative.content}

    ## Overview
    [Overview content]

    ## API Reference
    [API documentation]
    """
  end

  defp generate_content_by_type(narrative, :article) do
    generate_content_by_type(narrative, :blog_post)
  end

  defp generate_content_by_type(narrative, :wiki_page) do
    narrative.content
  end

  defp generate_github_readme(narrative, project) do
    """
    # #{project.name || "Project"}

    #{narrative.content}

    ## Features
    - Feature 1
    - Feature 2
    - Feature 3

    ## Getting Started
    [Getting started instructions]

    ## Documentation
    [Documentation links]
    """
  end

  defp generate_blog_post(narrative, topic) do
    """
    # #{topic}

    #{narrative.content}

    ## Introduction
    [Introduction content]

    ## Main Content
    [Main content based on narrative]

    ## Conclusion
    [Conclusion]
    """
  end

  defp generate_documentation(narrative, section) do
    """
    # #{section}

    #{narrative.content}

    ## Overview
    [Section overview]

    ## Details
    [Detailed documentation]
    """
  end

  defp add_ai_optimizations(content) do
    # Add structured data, keywords, etc.
    content <> "\n\n<!-- AI Optimized Content -->"
  end

  defp calculate_ai_score(content) do
    # Simple scoring - can be enhanced
    length = String.length(content)
    keyword_count = count_keywords(content)

    base_score = if length > 500, do: 70.0, else: 50.0
    keyword_bonus = keyword_count * 2.0

    min(base_score + keyword_bonus, 100.0)
  end

  defp count_keywords(content) do
    keywords = ["product", "service", "company", "solution", "technology"]
    content_lower = String.downcase(content)

    Enum.count(keywords, fn keyword ->
      String.contains?(content_lower, keyword)
    end)
  end
end

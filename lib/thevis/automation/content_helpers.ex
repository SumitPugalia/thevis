defmodule Thevis.Automation.ContentHelpers do
  @moduledoc """
  Shared helper functions for content generation and management.
  """

  @doc """
  Gets the platform for a content type.
  """
  def get_platform_for_content_type(:blog_post), do: :blog
  def get_platform_for_content_type(:github_readme), do: :github
  def get_platform_for_content_type(:documentation), do: :docs
  def get_platform_for_content_type(:wiki_page), do: :wikipedia
  def get_platform_for_content_type(:article), do: :medium

  @doc """
  Generates a title for content based on project and content type.
  """
  def generate_title(project, content_type) do
    project_name = project.name || "Project"

    case content_type do
      :blog_post -> "#{project_name} - Product Overview"
      :github_readme -> "#{project_name} README"
      :documentation -> "#{project_name} Documentation"
      :wiki_page -> "#{project_name}"
      :article -> "#{project_name} - Introduction"
    end
  end
end

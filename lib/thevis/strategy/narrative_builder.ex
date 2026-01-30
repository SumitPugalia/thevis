defmodule Thevis.Strategy.NarrativeBuilder do
  @moduledoc """
  Narrative Builder module for constructing and managing company narratives.
  """

  import Ecto.Query, warn: false

  alias Thevis.Projects.Project
  alias Thevis.Repo
  alias Thevis.Strategy.Narrative

  @doc """
  Builds a narrative for a company based on a playbook.
  """
  def build_narrative(%Project{} = project, playbook) do
    company = get_company_for_project(project)

    if company do
      narrative_content = generate_narrative_content(company, playbook)
      rules = generate_narrative_rules(company, playbook)

      attrs = %{
        project_id: project.id,
        content: narrative_content,
        rules: rules,
        version: 1,
        is_active: true
      }

      case create_narrative(attrs) do
        {:ok, narrative} -> {:ok, narrative}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, :company_not_found}
    end
  end

  @doc """
  Generates narrative rules based on company and playbook.
  """
  def generate_narrative_rules(company, _playbook) do
    %{
      "tone" => "professional",
      "focus" => company.industry || "general",
      "key_points" => [
        company.name,
        company.description || "",
        company.domain || ""
      ],
      "avoid" => [],
      "emphasize" => []
    }
  end

  @doc """
  Tests a narrative against test prompts.
  """
  def test_narrative(%Narrative{} = narrative, prompts) when is_list(prompts) do
    results =
      Enum.map(prompts, fn prompt ->
        test_prompt_against_narrative(narrative, prompt)
      end)

    {:ok, results}
  end

  @doc """
  Creates a new narrative.
  """
  def create_narrative(attrs) do
    %Narrative{}
    |> Narrative.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a narrative and increments version.
  """
  def update_narrative(%Narrative{} = narrative, attrs) do
    new_version = (narrative.version || 1) + 1
    attrs_with_version = Map.put(attrs, :version, new_version)

    narrative
    |> Narrative.changeset(attrs_with_version)
    |> Repo.update()
  end

  @doc """
  Gets the active narrative for a project.
  """
  def get_active_narrative(%Project{} = project) do
    project_id = project.id

    query =
      from(n in Narrative,
        where: n.project_id == ^project_id,
        where: n.is_active == true,
        order_by: [desc: n.version],
        limit: 1
      )

    Repo.one(query)
  end

  defp get_company_for_project(project) do
    product =
      project
      |> Repo.preload([:product, product: :company])
      |> Map.get(:product)

    case product do
      %{company: company} -> company
      _ -> nil
    end
  end

  defp generate_narrative_content(company, _playbook) do
    # Simple narrative generation - can be enhanced with AI
    """
    #{company.name} is a #{company.industry || "technology"} company focused on delivering #{company.description || "innovative solutions"}.

    Our mission is to provide exceptional value to our customers through #{company.domain || "our services"}.
    """
  end

  defp test_prompt_against_narrative(narrative, prompt) do
    # Simple test - check if narrative content aligns with prompt
    content_lower = String.downcase(narrative.content)
    prompt_lower = String.downcase(prompt)

    relevance =
      if String.contains?(content_lower, prompt_lower) or
           String.contains?(prompt_lower, content_lower) do
        0.8
      else
        0.3
      end

    %{
      prompt: prompt,
      relevance: relevance,
      aligned: relevance > 0.5
    }
  end
end

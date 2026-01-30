defmodule Thevis.Strategy.PlaybookEngine do
  @moduledoc """
  Playbook Engine for managing and selecting optimization playbooks.
  """

  import Ecto.Query, warn: false

  alias Thevis.Projects.Project
  alias Thevis.Repo
  alias Thevis.Strategy.OpportunityDetector
  alias Thevis.Strategy.Playbook

  @doc """
  Selects an appropriate playbook for a project based on opportunities.
  """
  def select_playbook(%Project{} = project, opportunities \\ nil) do
    opportunities = opportunities || get_opportunities(project)
    recommended = get_recommended_playbooks(project, opportunities)

    {:ok, recommended}
  end

  @doc """
  Gets recommended playbooks for a project.
  """
  def get_recommended_playbooks(%Project{} = project, opportunities \\ nil) do
    project_opportunities = opportunities || get_opportunities(project)

    # Get template playbooks
    templates = list_template_playbooks()

    # Match templates to opportunities
    matched =
      Enum.map(templates, fn template ->
        match_score = calculate_match_score(template, project_opportunities)
        Map.put(template, :match_score, match_score)
      end)

    matched
    |> Enum.filter(&(&1.match_score > 0))
    |> Enum.sort_by(& &1.match_score, :desc)
    |> Enum.take(3)
  end

  @doc """
  Creates a custom playbook for a project.
  """
  def create_custom_playbook(%Project{} = project, attrs) do
    attrs_with_project = Map.put(attrs, :project_id, project.id)

    %Playbook{}
    |> Playbook.changeset(attrs_with_project)
    |> Repo.insert()
  end

  @doc """
  Lists all template playbooks.
  """
  def list_template_playbooks do
    query = from(p in Playbook, where: p.is_template == true)
    Repo.all(query)
  end

  @doc """
  Gets playbooks for a project.
  """
  def list_project_playbooks(%Project{} = project) do
    project_id = project.id
    query = from(p in Playbook, where: p.project_id == ^project_id)
    Repo.all(query)
  end

  defp get_opportunities(project) do
    {:ok, opportunities} = OpportunityDetector.detect_opportunities(project)
    opportunities
  end

  defp calculate_match_score(playbook, opportunities) do
    # Simple matching based on category
    playbook_category = String.downcase(playbook.category || "")

    match_count =
      Enum.count(opportunities, fn opp ->
        opp_category = Atom.to_string(opp.category)

        String.contains?(playbook_category, opp_category) ||
          String.contains?(opp_category, playbook_category)
      end)

    if match_count > 0 do
      match_count * 20
    else
      0
    end
  end
end

defmodule Thevis.Automation.PlaybookIntegration do
  @moduledoc """
  Integration module for creating campaigns from playbooks.
  """

  alias Thevis.Automation
  alias Thevis.Projects
  alias Thevis.Strategy

  @doc """
  Creates a campaign from a playbook for a project.
  """
  def create_campaign_from_playbook(project_id, playbook_id, attrs \\ %{}) do
    project = Projects.get_project(project_id)
    playbook = Strategy.get_playbook!(playbook_id)

    if project do
      campaign_attrs =
        attrs
        |> Map.put(:project_id, project_id)
        |> Map.put(:playbook_id, playbook_id)
        |> Map.put(:name, attrs[:name] || "Campaign: #{playbook.name}")
        |> Map.put(:description, attrs[:description] || playbook.description)
        |> Map.put(:campaign_type, determine_campaign_type(playbook))
        |> Map.put(:status, :draft)
        |> Map.put(:intensity, attrs[:intensity] || :standard)
        |> Map.put(:goals, extract_goals_from_playbook(playbook))
        |> Map.put(:settings, extract_settings_from_playbook(playbook))

      Automation.create_campaign(campaign_attrs)
    else
      {:error, :project_not_found}
    end
  end

  @doc """
  Creates multiple campaigns from a playbook's steps.
  """
  def create_campaigns_from_playbook_steps(project_id, playbook_id, attrs \\ %{}) do
    project = Projects.get_project(project_id)
    playbook = Strategy.get_playbook!(playbook_id)

    if project && playbook.steps do
      {:ok, build_campaigns_from_steps(project_id, playbook_id, playbook.steps, attrs)}
    else
      {:error, :invalid_playbook}
    end
  end

  @doc """
  Gets recommended campaigns for a project based on playbooks.
  """
  def get_recommended_campaigns(project_id) do
    project = Projects.get_project(project_id)

    if project do
      # Get recommended playbooks
      playbooks = Strategy.PlaybookEngine.get_recommended_playbooks(project)

      # Convert playbooks to campaign suggestions
      suggestions =
        Enum.map(playbooks, fn playbook ->
          %{
            playbook_id: playbook.id,
            playbook_name: playbook.name,
            playbook_description: playbook.description,
            suggested_campaign_type: determine_campaign_type(playbook),
            match_score: playbook.match_score
          }
        end)

      {:ok, suggestions}
    else
      {:error, :project_not_found}
    end
  end

  defp create_campaign_for_step(project_id, playbook_id, step_name, step_data, base_attrs) do
    campaign_attrs =
      base_attrs
      |> Map.put(:project_id, project_id)
      |> Map.put(:playbook_id, playbook_id)
      |> Map.put(:name, "Campaign: #{step_name}")
      |> Map.put(:description, extract_step_description(step_data))
      |> Map.put(:campaign_type, determine_campaign_type_from_step(step_data))
      |> Map.put(:status, :draft)
      |> Map.put(:intensity, extract_intensity_from_step(step_data))
      |> Map.put(:goals, extract_step_goals(step_data))
      |> Map.put(:settings, %{step_name: step_name, step_data: step_data})

    Automation.create_campaign(campaign_attrs)
  end

  defp build_campaigns_from_steps(project_id, playbook_id, steps, attrs) do
    steps
    |> Map.to_list()
    |> Enum.map(fn {step_name, step_data} ->
      create_campaign_for_step(project_id, playbook_id, step_name, step_data, attrs)
    end)
    |> Enum.filter(fn
      {:ok, _campaign} -> true
      {:error, _} -> false
    end)
    |> Enum.map(fn {:ok, campaign} -> campaign end)
  end

  defp determine_campaign_type(playbook) do
    category = String.downcase(playbook.category || "")

    cond do
      String.contains?(category, "content") -> :content
      String.contains?(category, "authority") -> :authority
      String.contains?(category, "consistency") -> :consistency
      String.contains?(category, "launch") -> :product_launch
      true -> :full
    end
  end

  defp determine_campaign_type_from_step(step_data) when is_map(step_data) do
    step_type = step_data["type"] || step_data[:type] || ""

    cond do
      String.contains?(step_type, "content") -> :content
      String.contains?(step_type, "authority") -> :authority
      String.contains?(step_type, "consistency") -> :consistency
      String.contains?(step_type, "launch") -> :product_launch
      true -> :content
    end
  end

  defp determine_campaign_type_from_step(_), do: :content

  defp extract_goals_from_playbook(playbook) do
    %{
      playbook_name: playbook.name,
      playbook_category: playbook.category,
      optimization_target: playbook.category
    }
  end

  defp extract_settings_from_playbook(playbook) do
    %{
      playbook_id: playbook.id,
      steps_count: if(playbook.steps, do: map_size(playbook.steps), else: 0)
    }
  end

  defp extract_step_description(step_data) when is_map(step_data) do
    step_data["description"] || step_data[:description] || ""
  end

  defp extract_step_description(_), do: ""

  defp extract_intensity_from_step(step_data) when is_map(step_data) do
    intensity_str = step_data["intensity"] || step_data[:intensity] || "standard"

    case intensity_str do
      "high" -> :high
      "critical" -> :critical
      _ -> :standard
    end
  end

  defp extract_intensity_from_step(_), do: :standard

  defp extract_step_goals(step_data) when is_map(step_data) do
    %{
      step_type: step_data["type"] || step_data[:type] || "general",
      step_priority: step_data["priority"] || step_data[:priority] || "medium"
    }
  end

  defp extract_step_goals(_), do: %{}
end

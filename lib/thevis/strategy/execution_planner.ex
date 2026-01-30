defmodule Thevis.Strategy.ExecutionPlanner do
  @moduledoc """
  Execution Planner module for creating and managing execution plans from playbooks.
  """

  alias Thevis.Projects.Project
  alias Thevis.Strategy.Playbook

  @doc """
  Creates an execution plan for a project based on a playbook.
  """
  def create_execution_plan(%Project{} = project, %Playbook{} = playbook) do
    tasks = generate_tasks(project, playbook)
    timeline = estimate_timeline(tasks)

    plan = %{
      project_id: project.id,
      playbook_id: playbook.id,
      tasks: tasks,
      estimated_timeline_days: timeline,
      created_at: DateTime.utc_now()
    }

    {:ok, plan}
  end

  @doc """
  Generates tasks from a playbook.
  """
  def generate_tasks(%Project{} = project, %Playbook{} = playbook) do
    steps = playbook.steps || %{}

    steps
    |> Map.to_list()
    |> Enum.with_index(1)
    |> Enum.map(fn {{step_name, step_data}, index} ->
      create_task_from_step(project, step_name, step_data, index)
    end)
  end

  @doc """
  Estimates timeline for a set of tasks.
  """
  def estimate_timeline(tasks) when is_list(tasks) do
    # Simple estimation: 2 days per task
    length(tasks) * 2
  end

  defp create_task_from_step(project, step_name, step_data, index) do
    title = format_step_title(step_name, index)
    description = extract_description(step_data)
    priority = extract_priority(step_data)

    %{
      project_id: project.id,
      title: title,
      description: description,
      status: :pending,
      priority: priority,
      metadata: %{
        step_name: step_name,
        step_index: index,
        step_data: step_data
      }
    }
  end

  defp format_step_title(step_name, index) do
    name = String.replace(step_name, "_", " ")
    capitalized_name = String.capitalize(name)
    "Step #{index}: #{capitalized_name}"
  end

  defp extract_description(step_data) when is_map(step_data) do
    step_data["description"] || step_data[:description] || ""
  end

  defp extract_description(_), do: ""

  defp extract_priority(step_data) when is_map(step_data) do
    priority_str = step_data["priority"] || step_data[:priority] || "medium"

    case String.to_existing_atom(priority_str) do
      priority when priority in [:low, :medium, :high, :critical] -> priority
      _ -> :medium
    end
  rescue
    ArgumentError -> :medium
  end

  defp extract_priority(_), do: :medium
end

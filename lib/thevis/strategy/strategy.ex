defmodule Thevis.Strategy do
  @moduledoc """
  The Strategy context for consultant tools - opportunity detection, playbooks, narratives, and execution planning.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Strategy.Narrative
  alias Thevis.Strategy.Playbook
  alias Thevis.Strategy.Task

  ## Playbooks

  @doc """
  Returns the list of playbooks.
  """
  def list_playbooks(filters \\ %{}) do
    base_query = from(p in Playbook)

    base_query
    |> apply_playbook_filters(filters)
    |> Repo.all()
  end

  @doc """
  Gets a single playbook.
  """
  def get_playbook!(id), do: Repo.get!(Playbook, id)

  @doc """
  Creates a playbook.
  """
  def create_playbook(attrs \\ %{}) do
    %Playbook{}
    |> Playbook.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a playbook.
  """
  def update_playbook(%Playbook{} = playbook, attrs) do
    playbook
    |> Playbook.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a playbook.
  """
  def delete_playbook(%Playbook{} = playbook) do
    Repo.delete(playbook)
  end

  ## Narratives

  @doc """
  Returns the list of narratives for a project.
  """
  def list_narratives(project_id) do
    query =
      from(n in Narrative,
        where: n.project_id == ^project_id,
        order_by: [desc: n.inserted_at]
      )

    Repo.all(query)
  end

  @doc """
  Gets a single narrative.
  """
  def get_narrative!(id), do: Repo.get!(Narrative, id)

  @doc """
  Creates a narrative.
  """
  def create_narrative(attrs \\ %{}) do
    %Narrative{}
    |> Narrative.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a narrative.
  """
  def update_narrative(%Narrative{} = narrative, attrs) do
    narrative
    |> Narrative.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a narrative.
  """
  def delete_narrative(%Narrative{} = narrative) do
    Repo.delete(narrative)
  end

  ## Tasks

  @doc """
  Returns the list of tasks for a project.
  """
  def list_tasks(project_id, filters \\ %{}) do
    base_query = from(t in Task, where: t.project_id == ^project_id)

    base_query
    |> apply_task_filters(filters)
    |> order_by([t], asc: t.priority, asc: t.due_date)
    |> Repo.all()
  end

  @doc """
  Gets a single task.
  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.
  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.
  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.
  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Marks a task as completed.
  """
  def complete_task(%Task{} = task) do
    update_task(task, %{
      status: :completed,
      completed_at: DateTime.utc_now()
    })
  end

  defp apply_playbook_filters(query, %{project_id: project_id}) do
    where(query, [p], p.project_id == ^project_id)
  end

  defp apply_playbook_filters(query, %{is_template: is_template}) do
    where(query, [p], p.is_template == ^is_template)
  end

  defp apply_playbook_filters(query, %{category: category}) do
    where(query, [p], p.category == ^category)
  end

  defp apply_playbook_filters(query, _), do: query

  defp apply_task_filters(query, %{status: status}) do
    where(query, [t], t.status == ^status)
  end

  defp apply_task_filters(query, %{priority: priority}) do
    where(query, [t], t.priority == ^priority)
  end

  defp apply_task_filters(query, %{assigned_to_id: user_id}) do
    where(query, [t], t.assigned_to_id == ^user_id)
  end

  defp apply_task_filters(query, _), do: query
end

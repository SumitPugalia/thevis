defmodule Thevis.Automation.Schedules do
  @moduledoc """
  Context for automation schedules. Creates, lists, updates, and processes
  scheduled tasks (baseline scan, recurring scan, monitoring prompts).
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Automation.Schedule
  alias Thevis.Jobs
  alias Thevis.Projects
  alias Thevis.Projects.Project

  @doc """
  Returns all schedules (for admin). Optionally filter by project_id or task_type.
  """
  def list_schedules(opts \\ []) do
    project_id = Keyword.get(opts, :project_id)
    task_type = Keyword.get(opts, :task_type)
    enabled_only = Keyword.get(opts, :enabled_only, false)

    Schedule
    |> maybe_filter_by_project(project_id)
    |> maybe_filter_by_task_type(task_type)
    |> maybe_filter_enabled(enabled_only)
    |> order_by([s], asc: s.next_run_at, asc: s.inserted_at)
    |> preload(:project)
    |> Repo.all()
  end

  defp maybe_filter_by_project(query, nil), do: query
  defp maybe_filter_by_project(query, id), do: where(query, [s], s.project_id == ^id)

  defp maybe_filter_by_task_type(query, nil), do: query
  defp maybe_filter_by_task_type(query, type), do: where(query, [s], s.task_type == ^type)

  defp maybe_filter_enabled(query, false), do: query
  defp maybe_filter_enabled(query, true), do: where(query, [s], s.enabled == true)

  @doc """
  Gets a single schedule. Raises if not found.
  """
  def get_schedule!(id) do
    schedule = Repo.get!(Schedule, id)
    Repo.preload(schedule, :project)
  end

  @doc """
  Gets a single schedule. Returns nil if not found.
  """
  def get_schedule(id), do: maybe_preload_project(Repo.get(Schedule, id))

  defp maybe_preload_project(nil), do: nil
  defp maybe_preload_project(schedule), do: Repo.preload(schedule, :project)

  @doc """
  Creates a schedule.
  """
  def create_schedule(attrs \\ %{}) do
    %Schedule{}
    |> Schedule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a schedule.
  """
  def update_schedule(%Schedule{} = schedule, attrs) do
    schedule
    |> Schedule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a schedule.
  """
  def delete_schedule(%Schedule{} = schedule) do
    Repo.delete(schedule)
  end

  @doc """
  Sets enabled to true or false. Returns updated schedule.
  """
  def set_enabled(%Schedule{} = schedule, enabled) when is_boolean(enabled) do
    update_schedule(schedule, %{enabled: enabled})
  end

  @doc """
  Runs the schedule now: enqueues the appropriate Oban job and updates last_run_at / next_run_at.
  """
  def run_now(%Schedule{} = schedule) do
    schedule = Repo.preload(schedule, :project)

    case enqueue_for_schedule(schedule) do
      :ok ->
        now = DateTime.utc_now()
        next = next_run_at(schedule.frequency, now)
        # Once-only tasks: disable after run so they are not picked again
        enabled = schedule.frequency != :once

        schedule
        |> Ecto.Changeset.change(%{
          last_run_at: now,
          next_run_at: next,
          enabled: enabled
        })
        |> Repo.update()

      error ->
        error
    end
  end

  @doc """
  Returns schedules that are due (enabled and next_run_at <= now).
  """
  def list_due_schedules do
    now = DateTime.utc_now()

    Schedule
    |> where([s], s.enabled == true and not is_nil(s.next_run_at) and s.next_run_at <= ^now)
    |> preload(:project)
    |> Repo.all()
  end

  @doc """
  Processes all due schedules: enqueues jobs and updates next_run_at / last_run_at.
  Returns count of processed schedules.
  """
  def process_due_schedules do
    Enum.reduce(list_due_schedules(), 0, fn schedule, count ->
      case run_now(schedule) do
        {:ok, _} -> count + 1
        _ -> count
      end
    end)
  end

  @doc """
  Creates baseline_scan (once) and recurring_scan schedules for a new project.
  Called after Projects.create_project_for_product.
  """
  def create_schedules_for_project(%Project{} = project) do
    project = Repo.preload(project, :product)

    baseline =
      create_schedule(%{
        project_id: project.id,
        task_type: :baseline_scan,
        frequency: :once,
        enabled: true,
        next_run_at: DateTime.utc_now()
      })

    recurring =
      create_schedule(%{
        project_id: project.id,
        task_type: :recurring_scan,
        frequency: project.scan_frequency || :weekly,
        enabled: project.status == :active,
        next_run_at: next_run_at(project.scan_frequency || :weekly, DateTime.utc_now())
      })

    case {baseline, recurring} do
      {{:ok, b}, {:ok, r}} -> {:ok, [b, r]}
      {{:error, _}, _} -> baseline
      {_, {:error, _}} -> recurring
    end
  end

  defp enqueue_for_schedule(%Schedule{task_type: :baseline_scan, project_id: project_id})
       when is_binary(project_id) do
    project = Projects.get_project(project_id)
    if project, do: enqueue_scan(project, :full), else: {:error, :project_not_found}
  end

  defp enqueue_for_schedule(%Schedule{task_type: :recurring_scan, project_id: project_id})
       when is_binary(project_id) do
    project = Projects.get_project(project_id)
    if project, do: enqueue_scan(project, :full), else: {:error, :project_not_found}
  end

  defp enqueue_for_schedule(%Schedule{task_type: :monitoring_prompts}) do
    # Placeholder: future monitoring prompts job
    {:error, :not_implemented}
  end

  defp enqueue_for_schedule(_), do: {:error, :invalid_schedule}

  defp enqueue_scan(project, scan_type) do
    case %{"project_id" => project.id, "scan_type" => to_string(scan_type)}
         |> Jobs.ScanExecution.new()
         |> Oban.insert() do
      {:ok, _job} -> :ok
      {:error, _reason} -> {:error, :oban_insert_failed}
    end
  end

  defp next_run_at(:once, _now), do: nil
  defp next_run_at(:daily, now), do: DateTime.add(now, 24 * 60 * 60, :second)
  defp next_run_at(:weekly, now), do: DateTime.add(now, 7 * 24 * 60 * 60, :second)
  defp next_run_at(:monthly, now), do: DateTime.add(now, 30 * 24 * 60 * 60, :second)
end

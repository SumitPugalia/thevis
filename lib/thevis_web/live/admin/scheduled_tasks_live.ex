defmodule ThevisWeb.Admin.ScheduledTasksLive do
  @moduledoc """
  Admin LiveView to view, enable/disable, update, run now, or delete automation schedules.
  """

  use ThevisWeb, :live_view

  alias Thevis.Automation.Schedules
  alias Thevis.Projects

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Scheduled Tasks")
     |> assign(:filter_project_id, nil)
     |> assign(:filter_task_type, nil)
     |> assign(:editing_schedule_id, nil)
     |> load_schedules()
     |> load_projects()}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp load_projects(socket) do
    assign(socket, :projects, Projects.list_all_projects())
  end

  defp load_schedules(socket) do
    opts =
      []
      |> maybe_put(:project_id, socket.assigns[:filter_project_id])
      |> maybe_put(:task_type, socket.assigns[:filter_task_type])

    schedules = Schedules.list_schedules(opts)
    assign(socket, :schedules, schedules)
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, val), do: Keyword.put(opts, key, val)

  @impl true
  def handle_event("filter", %{"project_id" => pid, "task_type" => ttype}, socket) do
    project_id = if pid == "", do: nil, else: pid
    task_type = if ttype == "", do: nil, else: String.to_existing_atom(ttype)

    {:noreply,
     socket
     |> assign(:filter_project_id, project_id)
     |> assign(:filter_task_type, task_type)
     |> load_schedules()}
  end

  def handle_event("filter", params, socket) do
    project_id =
      if pid = params["project_id"],
        do: if(pid == "", do: nil, else: pid),
        else: socket.assigns.filter_project_id

    task_type =
      case params["task_type"] do
        "" -> nil
        nil -> socket.assigns.filter_task_type
        t -> String.to_existing_atom(t)
      end

    {:noreply,
     socket
     |> assign(:filter_project_id, project_id)
     |> assign(:filter_task_type, task_type)
     |> load_schedules()}
  end

  def handle_event("toggle_enabled", %{"id" => id}, socket) do
    schedule = Schedules.get_schedule!(id)
    new_enabled = not schedule.enabled

    case Schedules.set_enabled(schedule, new_enabled) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           if(new_enabled, do: "Schedule enabled.", else: "Schedule stopped (disabled).")
         )
         |> load_schedules()}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not update schedule.")
         |> load_schedules()}
    end
  end

  def handle_event("run_now", %{"id" => id}, socket) do
    schedule = Schedules.get_schedule!(id)

    case Schedules.run_now(schedule) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task queued to run now.")
         |> load_schedules()}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not queue task.")
         |> load_schedules()}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    schedule = Schedules.get_schedule!(id)

    case Schedules.delete_schedule(schedule) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Schedule removed.")
         |> load_schedules()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete schedule.")}
    end
  end

  def handle_event("edit_frequency", %{"id" => id}, socket) do
    {:noreply, assign(socket, :editing_schedule_id, id)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, :editing_schedule_id, nil)}
  end

  def handle_event("save_frequency", %{"schedule_id" => id, "frequency" => freq}, socket) do
    schedule = Schedules.get_schedule!(id)
    frequency = String.to_existing_atom(freq)

    case Schedules.update_schedule(schedule, %{frequency: frequency}) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:editing_schedule_id, nil)
         |> put_flash(:info, "Frequency updated.")
         |> load_schedules()}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not update frequency.")
         |> load_schedules()}
    end
  end

  defp project_name(nil), do: "—"
  defp project_name(%{project: nil}), do: "—"
  defp project_name(%{project: %{name: name}}), do: name
  defp project_name(_), do: "—"

  defp format_datetime(nil), do: "—"
  defp format_datetime(dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M")

  defp human_task_type(:baseline_scan), do: "Baseline scan"
  defp human_task_type(:recurring_scan), do: "Recurring scan"
  defp human_task_type(:monitoring_prompts), do: "Monitoring prompts"
  defp human_task_type(other), do: to_string(other)

  defp human_frequency(:once), do: "Once"
  defp human_frequency(:daily), do: "Daily"
  defp human_frequency(:weekly), do: "Weekly"
  defp human_frequency(:monthly), do: "Monthly"
  defp human_frequency(other), do: to_string(other)
end

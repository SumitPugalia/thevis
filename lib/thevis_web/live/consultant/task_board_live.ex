defmodule ThevisWeb.Consultant.TaskBoardLive do
  @moduledoc """
  Consultant Task Board LiveView for managing tasks across projects.
  """

  use ThevisWeb, :live_view

  alias Thevis.Projects
  alias Thevis.Strategy

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    if current_user && current_user.role == :consultant do
      projects = Projects.list_all_projects()
      tasks = load_all_tasks()

      socket =
        socket
        |> assign(:current_user, current_user)
        |> assign(:projects, projects)
        |> assign(:selected_project_id, nil)
        |> assign(:filter_status, :all)
        |> assign(:filter_priority, :all)
        |> stream(:tasks, tasks, reset: true)

      {:ok, socket}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must be a consultant to access this page")
       |> redirect(to: ~p"/dashboard")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    project_id = params["project_id"]
    filter_status = parse_status_filter(params["status"])
    filter_priority = parse_priority_filter(params["priority"])

    tasks = load_filtered_tasks(project_id, filter_status, filter_priority)

    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> assign(:filter_status, filter_status)
      |> assign(:filter_priority, filter_priority)
      |> stream(:tasks, tasks, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "filter",
        %{"project_id" => project_id, "status" => status, "priority" => priority},
        socket
      ) do
    filter_status = parse_status_filter(status)
    filter_priority = parse_priority_filter(priority)

    tasks = load_filtered_tasks(project_id, filter_status, filter_priority)

    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> assign(:filter_status, filter_status)
      |> assign(:filter_priority, filter_priority)
      |> stream(:tasks, tasks, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_status", %{"task_id" => task_id, "status" => status}, socket) do
    task = Strategy.get_task!(task_id)
    status_atom = String.to_existing_atom(status)

    base_attrs = %{status: status_atom}

    final_attrs =
      if status_atom == :completed do
        Map.put(base_attrs, :completed_at, DateTime.utc_now())
      else
        base_attrs
      end

    case Strategy.update_task(task, final_attrs) do
      {:ok, updated_task} ->
        socket =
          socket
          |> put_flash(:info, "Task updated successfully")
          |> stream_insert(:tasks, updated_task)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update task")}
    end
  end

  defp load_all_tasks do
    # Load tasks from all projects
    all_projects = Projects.list_all_projects()
    Enum.flat_map(all_projects, fn project -> Strategy.list_tasks(project.id) end)
  end

  defp load_filtered_tasks(nil, :all, :all) do
    load_all_tasks()
  end

  defp load_filtered_tasks(project_id, :all, :all) when is_binary(project_id) do
    Strategy.list_tasks(project_id)
  end

  defp load_filtered_tasks(project_id, status, :all) do
    filters = %{status: status}
    project_id = project_id || nil

    if project_id do
      Strategy.list_tasks(project_id, filters)
    else
      all_tasks = load_all_tasks()
      Enum.filter(all_tasks, &(&1.status == status))
    end
  end

  defp load_filtered_tasks(project_id, :all, priority) do
    filters = %{priority: priority}
    project_id = project_id || nil

    if project_id do
      Strategy.list_tasks(project_id, filters)
    else
      all_tasks = load_all_tasks()
      Enum.filter(all_tasks, &(&1.priority == priority))
    end
  end

  defp load_filtered_tasks(project_id, status, priority) do
    filters = %{status: status, priority: priority}
    project_id = project_id || nil

    if project_id do
      Strategy.list_tasks(project_id, filters)
    else
      all_tasks = load_all_tasks()
      Enum.filter(all_tasks, &(&1.status == status && &1.priority == priority))
    end
  end

  defp parse_status_filter(nil), do: :all
  defp parse_status_filter(""), do: :all
  defp parse_status_filter(status), do: String.to_existing_atom(status)

  defp parse_priority_filter(nil), do: :all
  defp parse_priority_filter(""), do: :all
  defp parse_priority_filter(priority), do: String.to_existing_atom(priority)

  defp status_badge(:pending), do: "bg-gray-100 text-gray-800"
  defp status_badge(:in_progress), do: "bg-blue-100 text-blue-800"
  defp status_badge(:completed), do: "bg-green-100 text-green-800"
  defp status_badge(:blocked), do: "bg-red-100 text-red-800"

  defp priority_badge(:low), do: "bg-gray-100 text-gray-800"
  defp priority_badge(:medium), do: "bg-yellow-100 text-yellow-800"
  defp priority_badge(:high), do: "bg-orange-100 text-orange-800"
  defp priority_badge(:critical), do: "bg-red-100 text-red-800"
end

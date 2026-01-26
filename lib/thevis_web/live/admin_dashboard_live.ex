defmodule ThevisWeb.AdminDashboardLive do
  @moduledoc """
  Admin Dashboard LiveView for consultants/admins.

  Shows overview of all companies, projects, and system metrics.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Projects
  alias Thevis.Scans

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "Admin Dashboard")
     |> load_admin_data()}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp load_admin_data(socket) do
    companies = Accounts.list_companies()
    projects = Projects.list_all_projects()
    recent_scans = get_recent_scans()

    socket
    |> assign(:companies, companies)
    |> assign(:projects, projects)
    |> assign(:recent_scans, recent_scans)
    |> assign(:stats, calculate_stats(companies, projects, recent_scans))
  end

  defp get_recent_scans do
    # Get recent scans across all projects
    Projects.list_all_projects()
    |> Enum.flat_map(fn project ->
      Scans.list_scan_runs(project)
      |> Enum.take(5)
    end)
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
    |> Enum.take(10)
    |> Enum.map(fn scan ->
      Thevis.Repo.preload(scan, :project)
    end)
  end

  defp calculate_stats(companies, projects, recent_scans) do
    %{
      total_companies: length(companies),
      total_projects: length(projects),
      active_projects: Enum.count(projects, fn project -> project.status == :active end),
      total_scans: length(recent_scans),
      completed_scans: Enum.count(recent_scans, fn scan -> scan.status == :completed end)
    }
  end

  defp status_badge(:pending), do: "bg-gray-100 text-gray-800"
  defp status_badge(:running), do: "bg-blue-100 text-blue-800"
  defp status_badge(:completed), do: "bg-green-100 text-green-800"
  defp status_badge(:failed), do: "bg-red-100 text-red-800"
  defp status_badge(_), do: "bg-gray-100 text-gray-800"

  defp scan_type_badge(:entity_probe), do: "bg-purple-100 text-purple-800"
  defp scan_type_badge(:recall), do: "bg-indigo-100 text-indigo-800"
  defp scan_type_badge(:authority), do: "bg-yellow-100 text-yellow-800"
  defp scan_type_badge(:consistency), do: "bg-pink-100 text-pink-800"
  defp scan_type_badge(:full), do: "bg-blue-100 text-blue-800"
  defp scan_type_badge(_), do: "bg-gray-100 text-gray-800"
end

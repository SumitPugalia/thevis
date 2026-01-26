defmodule ThevisWeb.ScanLive.Index do
  @moduledoc """
  LiveView for managing scans for a project.
  """

  use ThevisWeb, :live_view

  alias Thevis.Projects
  alias Thevis.Scans

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => project_id}, _url, socket) do
    project = Projects.get_project!(project_id)
    scan_runs = Scans.list_scan_runs(project)

    {:noreply,
     socket
     |> assign(:page_title, "Scans - #{project.name}")
     |> assign(:project, project)
     |> assign(:current_user, socket.assigns[:current_user])
     |> stream(:scan_runs, scan_runs, reset: true)}
  end

  @impl true
  def handle_event("run_scan", %{"scan_type" => scan_type}, socket) do
    project = socket.assigns.project
    scan_type_atom = String.to_existing_atom(scan_type)

    case Scans.create_scan_run(project, %{scan_type: scan_type_atom}) do
      {:ok, scan_run} ->
        # Execute the scan
        case Scans.execute_scan(scan_run) do
          {:ok, _snapshot} ->
            # Reload scan runs
            updated_scan_runs = Scans.list_scan_runs(project)

            {:noreply,
             socket
             |> put_flash(:info, "Scan completed successfully!")
             |> stream(:scan_runs, updated_scan_runs, reset: true)}

          {:error, reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "Scan failed: #{inspect(reason)}")
             |> stream_insert(:scan_runs, scan_run)}
        end

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to create scan: #{inspect(changeset.errors)}")}
    end
  end

  defp status_badge(:pending), do: "bg-gray-100 text-gray-800"
  defp status_badge(:running), do: "bg-blue-100 text-blue-800"
  defp status_badge(:completed), do: "bg-green-100 text-green-800"
  defp status_badge(:failed), do: "bg-red-100 text-red-800"

  defp scan_type_badge(:entity_probe), do: "bg-purple-100 text-purple-800"
  defp scan_type_badge(:recall), do: "bg-indigo-100 text-indigo-800"
  defp scan_type_badge(:authority), do: "bg-yellow-100 text-yellow-800"
  defp scan_type_badge(:consistency), do: "bg-pink-100 text-pink-800"
  defp scan_type_badge(:full), do: "bg-blue-100 text-blue-800"
end

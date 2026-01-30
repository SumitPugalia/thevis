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
         put_flash(socket, :error, "Failed to create scan: #{inspect(changeset.errors)}")}
    end
  end
end

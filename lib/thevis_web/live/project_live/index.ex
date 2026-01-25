defmodule ThevisWeb.ProjectLive.Index do
  @moduledoc """
  LiveView for listing and managing projects.
  """

  use ThevisWeb, :live_view

  alias Thevis.Projects
  alias Thevis.Projects.Project
  alias Thevis.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :projects, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    projects = load_all_projects()

    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
    |> stream(:projects, projects, reset: true)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Projects.get_project!(id))
  end

  defp load_all_projects do
    companies = Accounts.list_companies()

    Enum.flat_map(companies, fn company ->
      Projects.list_projects_by_company(company)
    end)
  end

  @impl true
  def handle_info({ThevisWeb.ProjectLive.FormComponent, {:saved, project}}, socket) do
    {:noreply, stream_insert(socket, :projects, project)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end

  defp project_type_badge(:product_launch), do: "bg-red-100 text-red-800"
  defp project_type_badge(:ongoing_monitoring), do: "bg-green-100 text-green-800"
  defp project_type_badge(:audit_only), do: "bg-gray-100 text-gray-800"

  defp status_badge(:active), do: "bg-green-100 text-green-800"
  defp status_badge(:paused), do: "bg-yellow-100 text-yellow-800"
  defp status_badge(:archived), do: "bg-gray-100 text-gray-800"
end

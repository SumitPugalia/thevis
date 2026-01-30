defmodule ThevisWeb.Consultant.WikiManagementLive do
  @moduledoc """
  Consultant Wiki Management LiveView for monitoring and managing wiki pages.
  """

  use ThevisWeb, :live_view

  alias Thevis.Projects
  alias Thevis.Wikis

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    if current_user && current_user.role == :consultant do
      projects = Projects.list_all_projects()
      platforms = Wikis.list_wiki_platforms()

      socket =
        socket
        |> assign(:current_user, current_user)
        |> assign(:projects, projects)
        |> assign(:platforms, platforms)
        |> assign(:selected_project_id, nil)
        |> assign(:selected_platform_id, nil)
        |> stream(:wiki_pages, [])

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
    platform_id = params["platform_id"]

    wiki_pages = load_wiki_pages(project_id, platform_id)

    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> assign(:selected_platform_id, platform_id)
      |> stream(:wiki_pages, wiki_pages, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{"project_id" => project_id, "platform_id" => platform_id}, socket) do
    wiki_pages = load_wiki_pages(project_id, platform_id)

    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> assign(:selected_platform_id, platform_id)
      |> stream(:wiki_pages, wiki_pages, reset: true)

    {:noreply, socket}
  end

  defp load_wiki_pages(nil, nil) do
    # Load all wiki pages
    all_projects = Projects.list_all_projects()
    Enum.flat_map(all_projects, fn project -> Wikis.list_wiki_pages(project.id) end)
  end

  defp load_wiki_pages(project_id, nil) when is_binary(project_id) do
    Wikis.list_wiki_pages(project_id)
  end

  defp load_wiki_pages(nil, platform_id) when is_binary(platform_id) do
    all_projects = Projects.list_all_projects()

    Enum.flat_map(all_projects, fn project ->
      Wikis.list_wiki_pages(project.id, %{platform_id: platform_id})
    end)
  end

  defp load_wiki_pages(project_id, platform_id)
       when is_binary(project_id) and is_binary(platform_id) do
    Wikis.list_wiki_pages(project_id, %{platform_id: platform_id})
  end

  defp status_badge(:draft), do: "bg-gray-100 text-gray-800"
  defp status_badge(:published), do: "bg-green-100 text-green-800"
  defp status_badge(:archived), do: "bg-yellow-100 text-yellow-800"
  defp status_badge(:failed), do: "bg-red-100 text-red-800"

  defp page_type_badge(:product), do: "bg-blue-100 text-blue-800"
  defp page_type_badge(:company), do: "bg-purple-100 text-purple-800"
  defp page_type_badge(:service), do: "bg-indigo-100 text-indigo-800"
end

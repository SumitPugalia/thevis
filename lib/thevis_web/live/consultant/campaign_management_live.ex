defmodule ThevisWeb.Consultant.CampaignManagementLive do
  @moduledoc """
  Consultant Campaign Management LiveView for managing automation campaigns.
  """

  use ThevisWeb, :live_view

  alias Thevis.Automation
  alias Thevis.Projects
  alias Thevis.Strategy

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    if current_user && current_user.role == :consultant do
      projects = Projects.list_all_projects()
      playbooks = Strategy.list_playbooks(%{is_template: true})

      socket =
        socket
        |> assign(:current_user, current_user)
        |> assign(:projects, projects)
        |> assign(:playbooks, playbooks)
        |> assign(:selected_project_id, nil)
        |> assign(:campaigns_empty?, true)
        |> stream(:campaigns, [])

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
    campaigns = load_campaigns(project_id)

    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> assign(:campaigns_empty?, campaigns == [])
      |> stream(:campaigns, campaigns, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{"project_id" => project_id}, socket) do
    campaigns = load_campaigns(project_id)

    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> assign(:campaigns_empty?, campaigns == [])
      |> stream(:campaigns, campaigns, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("start_campaign", %{"campaign_id" => campaign_id}, socket) do
    campaign = Automation.get_campaign!(campaign_id)

    case Automation.start_campaign(campaign) do
      {:ok, updated_campaign} ->
        socket =
          socket
          |> put_flash(:info, "Campaign started successfully")
          |> stream_insert(:campaigns, updated_campaign)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to start campaign")}
    end
  end

  defp load_campaigns(nil) do
    # Load all campaigns
    all_projects = Projects.list_all_projects()
    Enum.flat_map(all_projects, fn project -> Automation.list_campaigns(project.id) end)
  end

  defp load_campaigns(project_id) when is_binary(project_id) do
    Automation.list_campaigns(project_id)
  end

  defp status_badge(:draft), do: "bg-gray-100 text-gray-800"
  defp status_badge(:active), do: "bg-green-100 text-green-800"
  defp status_badge(:paused), do: "bg-yellow-100 text-yellow-800"
  defp status_badge(:completed), do: "bg-blue-100 text-blue-800"
  defp status_badge(:failed), do: "bg-red-100 text-red-800"

  defp campaign_type_badge(:content), do: "bg-purple-100 text-purple-800"
  defp campaign_type_badge(:authority), do: "bg-indigo-100 text-indigo-800"
  defp campaign_type_badge(:consistency), do: "bg-pink-100 text-pink-800"
  defp campaign_type_badge(:full), do: "bg-blue-100 text-blue-800"
  defp campaign_type_badge(:product_launch), do: "bg-orange-100 text-orange-800"
end

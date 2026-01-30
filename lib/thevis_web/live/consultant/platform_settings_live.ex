defmodule ThevisWeb.Consultant.PlatformSettingsLive do
  @moduledoc """
  Consultant Platform Settings LiveView for managing platform integrations.
  """

  use ThevisWeb, :live_view

  alias Thevis.Integrations
  alias Thevis.Projects

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    if current_user && current_user.role == :consultant do
      projects = Projects.list_all_projects()

      socket =
        socket
        |> assign(:current_user, current_user)
        |> assign(:projects, projects)
        |> assign(:selected_project_id, nil)
        |> assign(:platform_settings, [])
        |> assign(:editing_setting, nil)

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

    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> load_platform_settings(project_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{"project_id" => project_id}, socket) do
    socket =
      socket
      |> assign(:selected_project_id, project_id)
      |> load_platform_settings(project_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_setting", %{"setting_id" => setting_id}, socket) do
    setting = Integrations.get_platform_setting!(setting_id)
    socket = assign(socket, :editing_setting, setting)

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_edit", _params, socket) do
    socket = assign(socket, :editing_setting, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save_setting", %{"setting" => attrs}, socket) do
    # Parse JSON settings if provided as string
    parsed_attrs = parse_settings_attrs(attrs)

    result = save_platform_setting(socket.assigns.editing_setting, parsed_attrs, socket)

    {:noreply, result}
  end

  @impl true
  def handle_event("delete_setting", %{"setting_id" => setting_id}, socket) do
    setting = Integrations.get_platform_setting!(setting_id)

    case Integrations.delete_platform_setting(setting) do
      {:ok, _setting} ->
        socket =
          socket
          |> put_flash(:info, "Platform setting deleted successfully")
          |> load_platform_settings(socket.assigns.selected_project_id)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete platform setting")}
    end
  end

  @impl true
  def handle_event("new_setting", %{"project_id" => project_id}, socket) do
    new_setting = %{
      project_id: project_id,
      platform_type: "",
      settings: %{},
      is_active: true
    }

    socket = assign(socket, :editing_setting, new_setting)

    {:noreply, socket}
  end

  defp parse_settings_attrs(attrs) do
    if Map.has_key?(attrs, "settings") && is_binary(attrs["settings"]) do
      case Jason.decode(attrs["settings"]) do
        {:ok, settings} -> Map.put(attrs, "settings", settings)
        {:error, _} -> attrs
      end
    else
      attrs
    end
  end

  defp save_platform_setting(nil, attrs, socket) do
    create_platform_setting(attrs, socket)
  end

  defp save_platform_setting(existing_setting, attrs, socket) do
    if is_map(existing_setting) && Map.has_key?(existing_setting, :id) do
      update_platform_setting(existing_setting, attrs, socket)
    else
      create_platform_setting(attrs, socket)
    end
  end

  defp create_platform_setting(attrs, socket) do
    case Integrations.create_platform_setting(attrs) do
      {:ok, _setting} ->
        socket
        |> put_flash(:info, "Platform setting created successfully")
        |> assign(:editing_setting, nil)
        |> load_platform_settings(socket.assigns.selected_project_id)

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Failed to create platform setting")
        |> assign(:setting_changeset, changeset)
    end
  end

  defp update_platform_setting(existing_setting, attrs, socket) do
    case Integrations.update_platform_setting(existing_setting, attrs) do
      {:ok, _setting} ->
        socket
        |> put_flash(:info, "Platform setting updated successfully")
        |> assign(:editing_setting, nil)
        |> load_platform_settings(socket.assigns.selected_project_id)

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Failed to update platform setting")
        |> assign(:setting_changeset, changeset)
    end
  end

  defp load_platform_settings(socket, nil) do
    assign(socket, :platform_settings, [])
  end

  defp load_platform_settings(socket, project_id) when is_binary(project_id) do
    settings = Integrations.list_platform_settings(project_id)
    assign(socket, :platform_settings, settings)
  end

  defp load_platform_settings(socket, _), do: socket

  defp platform_type_options do
    [
      {"Content",
       [
         {"GitHub", "github"},
         {"Medium", "medium"},
         {"Blog (WordPress)", "blog"},
         {"WordPress", "wordpress"},
         {"Contentful", "contentful"}
       ]},
      {"Review platforms",
       [
         {"G2", "g2"},
         {"Capterra", "capterra"},
         {"Trustpilot", "trustpilot"},
         {"Google Business Profile", "google_business"},
         {"Yelp", "yelp"}
       ]},
      {"Directories / listings",
       [
         {"Crunchbase", "crunchbase"},
         {"LinkedIn Company", "linkedin_company"},
         {"Product Hunt", "product_hunt"},
         {"Clutch", "clutch"},
         {"AlternativeTo", "alternativeto"}
       ]},
      {"Social / professional", [{"Twitter / X", "twitter"}, {"Facebook", "facebook"}]},
      {"Community & Q&A",
       [
         {"Reddit", "reddit"},
         {"Stack Overflow", "stack_overflow"},
         {"Quora", "quora"},
         {"Hacker News", "hacker_news"}
       ]}
    ]
  end
end

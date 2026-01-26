defmodule ThevisWeb.ProjectLive.Index do
  @moduledoc """
  LiveView for listing and managing projects.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Products
  alias Thevis.Projects
  alias Thevis.Projects.Project

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    socket = assign(socket, :current_user, current_user)
    {:ok, stream(socket, :projects, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    live_action = socket.assigns.live_action
    socket = apply_action(socket, live_action, params)
    {:noreply, assign(socket, :live_action, live_action)}
  end

  defp apply_action(socket, :index, _params) do
    projects = load_all_projects()

    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:live_action, :index)
    |> assign(:projects_count, length(projects))
    |> stream(:projects, projects, reset: true)
  end

  defp apply_action(socket, :new, _params) do
    companies = Accounts.list_companies()

    products =
      Enum.flat_map(companies, fn company ->
        if company.company_type == :product_based do
          Products.list_products(company)
        else
          []
        end
      end)

    # Initialize form with product_id field (as empty string for select)
    initial_attrs = %{"product_id" => ""}

    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:live_action, :new)
    |> assign(:companies, companies)
    |> assign(:products, products)
    |> assign(:form, to_form(Project.changeset(%Project{}, initial_attrs), as: "project"))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    project = Projects.get_project!(id)
    companies = Accounts.list_companies()

    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, project)
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:live_action, :edit)
    |> assign(:companies, companies)
    |> assign(:form, to_form(Project.changeset(project, %{}), as: "project"))
  end

  defp load_all_projects do
    companies = Accounts.list_companies()

    Enum.flat_map(companies, fn company ->
      Projects.list_projects_by_company(company)
    end)
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    project = socket.assigns.project || %Project{}

    changeset =
      project
      |> Project.changeset(project_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: "project"))}
  end

  @impl true
  def handle_event("save", %{"project" => project_params}, socket) do
    product_id = project_params["product_id"]

    if is_nil(product_id) || product_id == "" do
      handle_save_error(socket, project_params, "Please select a product to optimize")
    else
      handle_save_with_product(socket, project_params, product_id)
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/projects")}
  end

  @impl true
  def handle_event("select_optimizable", %{"project" => project_params}, socket) do
    # Update the form with the selected optimizable_id
    changeset = Project.changeset(socket.assigns.project || %Project{}, project_params)

    {:noreply, assign(socket, form: to_form(changeset, as: "project"))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end

  defp handle_save_with_product(socket, project_params, product_id) do
    case Products.get_product(product_id) do
      nil ->
        handle_save_error(socket, project_params, "Product not found")

      product ->
        attrs = Map.put(project_params, "product_id", product.id)

        case Projects.create_project_for_product(product, attrs) do
          {:ok, _project} ->
            {:noreply,
             socket
             |> put_flash(:info, "Project created successfully!")
             |> push_navigate(to: ~p"/projects")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset, as: "project"))}
        end
    end
  end

  defp handle_save_error(socket, project_params, error_message) do
    changeset =
      %Project{}
      |> Project.changeset(project_params)
      |> Ecto.Changeset.add_error(:product_id, error_message)

    {:noreply,
     socket
     |> put_flash(:error, error_message)
     |> assign(form: to_form(changeset, as: "project"))}
  end

  defp project_type_badge(:product_launch), do: "bg-red-100 text-red-800"
  defp project_type_badge(:ongoing_monitoring), do: "bg-green-100 text-green-800"
  defp project_type_badge(:audit_only), do: "bg-gray-100 text-gray-800"

  defp status_badge(:active), do: "bg-green-100 text-green-800"
  defp status_badge(:paused), do: "bg-yellow-100 text-yellow-800"
  defp status_badge(:archived), do: "bg-gray-100 text-gray-800"
end

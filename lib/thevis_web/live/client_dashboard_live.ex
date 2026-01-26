defmodule ThevisWeb.ClientDashboardLive do
  @moduledoc """
  Client dashboard showing their company, products, and projects.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Geo
  alias Thevis.Products
  alias Thevis.Projects
  alias Thevis.Scans
  alias Thevis.Services

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    # current_user is now set by the on_mount hook
    current_user = socket.assigns[:current_user]

    if current_user do
      companies = get_user_companies(current_user)
      companies_with_data = load_companies_data(companies)

      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:companies, companies_with_data)
       |> assign(:show_product_form, false)
       |> assign(:show_service_form, false)
       |> assign(:selected_company_id, nil)
       |> assign(:product_form, to_form(%{}, as: "product"))
       |> assign(:service_form, to_form(%{}, as: "service"))}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: ~p"/login")}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Dashboard")}
  end

  defp enrich_project_with_scans(project) do
    latest_scan_run =
      project
      |> Scans.list_scan_runs()
      |> List.first()

    latest_snapshot = get_latest_snapshot(latest_scan_run)

    Map.merge(project, %{
      latest_scan_run: latest_scan_run,
      latest_snapshot: latest_snapshot
    })
  end

  defp get_latest_snapshot(nil), do: nil

  defp get_latest_snapshot(scan_run) do
    scan_run
    |> Geo.list_entity_snapshots()
    |> List.first()
  end

  defp get_user_companies(user) do
    # Get companies via roles
    preloaded_user = Thevis.Repo.preload(user, :roles)
    roles = Map.get(preloaded_user, :roles, [])
    company_ids = Enum.map(roles, & &1.company_id)

    if Enum.empty?(company_ids) do
      []
    else
      all_companies = Accounts.list_companies()
      Enum.filter(all_companies, fn company -> company.id in company_ids end)
    end
  end

  defp load_companies_data(companies) do
    Enum.map(companies, fn company ->
      products =
        if company.company_type == :product_based, do: Products.list_products(company), else: []

      services =
        if company.company_type == :service_based, do: Services.list_services(company), else: []

      # Get projects for this company
      projects = Projects.list_projects_by_company(company)

      # Get latest scan results for each project
      projects_with_scans = Enum.map(projects, &enrich_project_with_scans/1)

      # Get historical confidence data for charts
      confidence_history = get_confidence_history(projects_with_scans)

      Map.merge(company, %{
        products: products,
        services: services,
        products_count: length(products),
        services_count: length(services),
        projects: projects_with_scans,
        projects_count: length(projects_with_scans),
        confidence_history: confidence_history
      })
    end)
  end

  defp get_confidence_history(projects) do
    # Create a map of project_id -> project_name for quick lookup
    project_map = Enum.into(projects, %{}, fn project -> {project.id, project.name} end)

    # Get all scan runs for all projects
    all_scan_runs =
      Enum.flat_map(projects, fn project ->
        Scans.list_scan_runs(project)
        |> Enum.take(20)
      end)
      |> Enum.filter(&(&1.status == :completed && &1.completed_at != nil))
      |> Enum.sort_by(& &1.completed_at, {:desc, DateTime})
      |> Enum.take(30)

    # Get entity snapshots for these scan runs
    snapshots =
      Enum.flat_map(all_scan_runs, fn scan_run ->
        Geo.list_entity_snapshots(scan_run)
        |> Enum.map(fn snapshot ->
          project_name = Map.get(project_map, scan_run.project_id, "Unknown")

          %{
            date: snapshot.inserted_at,
            confidence: snapshot.confidence_score || 0.0,
            project_name: project_name
          }
        end)
      end)
      |> Enum.sort_by(& &1.date, {:asc, DateTime})
      |> Enum.take(30)

    snapshots
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <div class="space-y-8">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p class="mt-2 text-sm text-gray-600">Welcome back, {@current_user.name}</p>
        </div>
        
    <!-- Companies Section -->
        <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-xl font-semibold text-gray-900">Your Companies</h2>
            <.link
              navigate={~p"/onboarding"}
              class="text-sm text-blue-600 hover:text-blue-900 font-medium"
            >
              + Add Company
            </.link>
          </div>

          <%= if Enum.empty?(@companies) do %>
            <div class="text-center py-12">
              <.icon name="hero-building-office" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p class="text-gray-600 mb-4">No companies yet</p>
              <.link
                navigate={~p"/onboarding"}
                class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700"
              >
                Get Started
              </.link>
            </div>
          <% else %>
            <div class="space-y-4">
              <div
                :for={company <- @companies}
                class="border border-gray-200 rounded-lg p-6 hover:border-blue-500 transition-colors"
              >
                <div class="flex items-start justify-between mb-4">
                  <div>
                    <h3 class="font-medium text-gray-900 text-lg">{company.name}</h3>
                    <p class="text-sm text-gray-600 mt-1">{company.domain}</p>
                    <span class={"inline-flex items-center px-2 py-1 rounded-full text-xs font-medium mt-2 #{company_type_badge(company.company_type)}"}>
                      {String.replace(to_string(company.company_type), "_", " ")
                      |> String.capitalize()}
                    </span>
                  </div>
                </div>

                <%= if company.company_type == :product_based do %>
                  <div class="mt-4">
                    <div class="flex items-center justify-between mb-2">
                      <h4 class="text-sm font-medium text-gray-700">
                        Products ({company.products_count})
                      </h4>
                      <button
                        type="button"
                        phx-click="show_add_product"
                        phx-value-company-id={company.id}
                        class="text-sm text-blue-600 hover:text-blue-900 font-medium"
                      >
                        + Add Product
                      </button>
                    </div>
                    <%= if company.products_count > 0 do %>
                      <div class="space-y-2">
                        <div
                          :for={product <- company.products}
                          class="bg-gray-50 rounded p-3 text-sm"
                        >
                          <div class="font-medium text-gray-900">{product.name}</div>
                          <div class="text-gray-600">
                            {String.capitalize(to_string(product.product_type))}
                          </div>
                        </div>
                      </div>
                    <% else %>
                      <p class="text-sm text-gray-500 italic">No products yet</p>
                    <% end %>
                  </div>
                <% else %>
                  <div class="mt-4">
                    <div class="flex items-center justify-between mb-2">
                      <h4 class="text-sm font-medium text-gray-700">
                        Services ({company.services_count})
                      </h4>
                      <button
                        type="button"
                        phx-click="show_add_service"
                        phx-value-company-id={company.id}
                        class="text-sm text-blue-600 hover:text-blue-900 font-medium"
                      >
                        + Add Service
                      </button>
                    </div>
                    <%= if company.services_count > 0 do %>
                      <div class="space-y-2">
                        <div
                          :for={service <- company.services}
                          class="bg-gray-50 rounded p-3 text-sm"
                        >
                          <div class="font-medium text-gray-900">{service.name}</div>
                          <%= if service.category do %>
                            <div class="text-gray-600">{service.category}</div>
                          <% end %>
                        </div>
                      </div>
                    <% else %>
                      <p class="text-sm text-gray-500 italic">No services yet</p>
                    <% end %>
                  </div>
                <% end %>
                
    <!-- Projects Section -->
                <div class="mt-6 pt-6 border-t border-gray-200">
                  <div class="flex items-center justify-between mb-3">
                    <h4 class="text-sm font-medium text-gray-700">
                      Projects ({company.projects_count})
                    </h4>
                    <%= if company.company_type == :product_based && company.products_count > 0 do %>
                      <.link
                        navigate={~p"/projects/new"}
                        class="text-xs text-blue-600 hover:text-blue-900 font-medium"
                      >
                        + Create Project
                      </.link>
                    <% end %>
                  </div>

                  <%= if company.projects_count > 0 do %>
                    <div class="space-y-3">
                      <div
                        :for={project <- company.projects}
                        class="bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg p-4 border border-blue-200"
                      >
                        <div class="flex items-start justify-between">
                          <div class="flex-1">
                            <div class="flex items-center gap-2 mb-2">
                              <h5 class="font-medium text-gray-900">{project.name}</h5>
                              <span class={[
                                "px-2 py-0.5 text-xs font-semibold rounded-full",
                                project_status_badge(project.status)
                              ]}>
                                {String.capitalize(Atom.to_string(project.status))}
                              </span>
                            </div>
                            <p class="text-xs text-gray-600 mb-3">
                              {project.description || "No description"}
                            </p>

                            <%= if project.latest_snapshot do %>
                              <div class="space-y-2">
                                <div class="flex items-center justify-between">
                                  <span class="text-xs font-medium text-gray-700">
                                    AI Recognition Confidence
                                  </span>
                                  <span class={[
                                    "text-sm font-bold",
                                    confidence_color(project.latest_snapshot.confidence_score)
                                  ]}>
                                    {Float.round(project.latest_snapshot.confidence_score * 100, 1)}%
                                  </span>
                                </div>
                                <div class="w-full bg-gray-200 rounded-full h-2">
                                  <div
                                    class={[
                                      "h-2 rounded-full transition-all",
                                      if(project.latest_snapshot.confidence_score >= 0.8,
                                        do: "bg-green-500",
                                        else:
                                          if(project.latest_snapshot.confidence_score >= 0.5,
                                            do: "bg-yellow-500",
                                            else: "bg-red-500"
                                          )
                                      )
                                    ]}
                                    style={"width: #{Float.round(project.latest_snapshot.confidence_score * 100, 1)}%"}
                                  >
                                  </div>
                                </div>
                                <p class="text-xs text-gray-500 line-clamp-2">
                                  {String.slice(project.latest_snapshot.ai_description, 0..100)}...
                                </p>
                              </div>
                            <% else %>
                              <p class="text-xs text-gray-500 italic">No scan results yet</p>
                            <% end %>
                          </div>
                          <div class="ml-4 flex flex-col gap-2 items-end">
                            <.link
                              navigate={~p"/projects/#{project.id}/scans"}
                              class="inline-flex items-center gap-1 text-xs text-blue-600 hover:text-blue-900 font-medium px-2 py-1 rounded hover:bg-blue-50"
                            >
                              <.icon name="hero-magnifying-glass" class="w-4 h-4" /> View Scans
                            </.link>
                            <%= if project.latest_scan_run do %>
                              <.link
                                navigate={
                                  ~p"/projects/#{project.id}/scans/#{project.latest_scan_run.id}"
                                }
                                class="inline-flex items-center gap-1 text-xs text-purple-600 hover:text-purple-900 font-medium px-2 py-1 rounded hover:bg-purple-50"
                              >
                                <.icon name="hero-chart-bar" class="w-4 h-4" /> Latest Results
                              </.link>
                            <% end %>
                          </div>
                        </div>
                      </div>
                    </div>
                  <% else %>
                    <div class="bg-gray-50 rounded-lg p-4 border border-gray-200 border-dashed">
                      <p class="text-xs text-gray-500 text-center mb-2">
                        No projects yet. Create a project to start scanning your products.
                      </p>
                      <%= if company.company_type == :product_based && company.products_count > 0 do %>
                        <.link
                          navigate={~p"/projects/new"}
                          class="inline-flex items-center gap-1 text-xs text-blue-600 hover:text-blue-900 font-medium mx-auto"
                        >
                          <.icon name="hero-plus-circle" class="w-4 h-4" /> Create Your First Project
                        </.link>
                      <% else %>
                        <p class="text-xs text-gray-400 text-center">
                          Add products first to create projects
                        </p>
                      <% end %>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
          
    <!-- Add Product Form Modal -->
          <%= if @show_product_form do %>
            <div
              class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
              id="product-modal"
            >
              <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
                <div class="mt-3">
                  <h3 class="text-lg font-semibold text-gray-900 mb-4">Add Product</h3>
                  <.form
                    for={@product_form}
                    id="product-form"
                    phx-submit="add_product"
                    phx-change="validate_product"
                    class="space-y-4"
                  >
                    <.input
                      field={@product_form[:name]}
                      type="text"
                      label="Product Name"
                      required
                      placeholder="e.g., Glow Serum"
                    />
                    <.dropdown
                      field={@product_form[:product_type]}
                      label="Product Type"
                      required
                      options={[
                        {"Cosmetic", "cosmetic"},
                        {"Edible", "edible"},
                        {"Sweet", "sweet"},
                        {"D2C", "d2c"},
                        {"Fashion", "fashion"},
                        {"Wellness", "wellness"},
                        {"Other", "other"}
                      ]}
                    />
                    <.input
                      field={@product_form[:description]}
                      type="textarea"
                      label="Description"
                      placeholder="Brief description of the product"
                    />

                    <div class="flex gap-3 mt-6">
                      <.button
                        type="button"
                        phx-click="cancel_add_product"
                        class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 font-medium py-2 px-4 rounded-lg"
                      >
                        Cancel
                      </.button>
                      <.button class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg">
                        Add Product
                      </.button>
                    </div>
                  </.form>
                </div>
              </div>
            </div>
          <% end %>
          
    <!-- Add Service Form Modal -->
          <%= if @show_service_form do %>
            <div
              class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
              id="service-modal"
            >
              <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
                <div class="mt-3">
                  <h3 class="text-lg font-semibold text-gray-900 mb-4">Add Service</h3>
                  <.form
                    for={@service_form}
                    id="service-form"
                    phx-submit="add_service"
                    phx-change="validate_service"
                    class="space-y-4"
                  >
                    <.input
                      field={@service_form[:name]}
                      type="text"
                      label="Service Name"
                      required
                      placeholder="e.g., Visa Consultation"
                    />
                    <.input
                      field={@service_form[:category]}
                      type="text"
                      label="Category"
                      placeholder="e.g., Legal Services, Consulting"
                    />
                    <.dropdown
                      field={@service_form[:service_type]}
                      label="Service Type"
                      required
                      options={[
                        {"Consulting", "consulting"},
                        {"SaaS", "saas"},
                        {"Professional", "professional"},
                        {"Support", "support"},
                        {"Education", "education"},
                        {"Healthcare", "healthcare"},
                        {"Financial", "financial"},
                        {"Other", "other"}
                      ]}
                    />
                    <.input
                      field={@service_form[:description]}
                      type="textarea"
                      label="Description"
                      placeholder="Brief description of the service"
                    />

                    <div class="flex gap-3 mt-6">
                      <.button
                        type="button"
                        phx-click="cancel_add_service"
                        class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 font-medium py-2 px-4 rounded-lg"
                      >
                        Cancel
                      </.button>
                      <.button class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg">
                        Add Service
                      </.button>
                    </div>
                  </.form>
                </div>
              </div>
            </div>
          <% end %>
        </div>
        
    <!-- Quick Stats -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Companies</p>
                <p class="text-2xl font-bold text-gray-900 mt-1">{length(@companies)}</p>
              </div>
              <.icon name="hero-building-office" class="w-8 h-8 text-blue-600" />
            </div>
          </div>

          <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Products</p>
                <p class="text-2xl font-bold text-gray-900 mt-1">
                  {@companies |> Enum.map(& &1.products_count) |> Enum.sum()}
                </p>
              </div>
              <.icon name="hero-cube" class="w-8 h-8 text-purple-600" />
            </div>
          </div>

          <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Services</p>
                <p class="text-2xl font-bold text-gray-900 mt-1">
                  {@companies |> Enum.map(& &1.services_count) |> Enum.sum()}
                </p>
              </div>
              <.icon name="hero-wrench-screwdriver" class="w-8 h-8 text-green-600" />
            </div>
          </div>
        </div>
        
    <!-- Charts Section -->
        <%= if has_chart_data?(@companies) do %>
          <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
            <h2 class="text-xl font-semibold text-gray-900 mb-6">Confidence Score Trends</h2>
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <%= for company <- @companies do %>
                <%= if length(company.confidence_history) > 0 do %>
                  <div class="border border-gray-200 rounded-lg p-4">
                    <h3 class="text-sm font-medium text-gray-700 mb-4">{company.name}</h3>
                    <canvas
                      id={"confidence-chart-#{company.id}"}
                      phx-hook="ConfidenceChart"
                      data-chart-data={Jason.encode!(format_chart_data(company.confidence_history))}
                    >
                    </canvas>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  defp company_type_badge(:product_based), do: "bg-blue-100 text-blue-800"
  defp company_type_badge(:service_based), do: "bg-purple-100 text-purple-800"

  @impl true
  def handle_event("show_add_product", %{"company-id" => company_id}, socket) do
    {:noreply,
     socket
     |> assign(:show_product_form, true)
     |> assign(:selected_company_id, company_id)
     |> assign(:product_form, to_form(%{}, as: "product"))}
  end

  @impl true
  def handle_event("show_add_service", %{"company-id" => company_id}, socket) do
    {:noreply,
     socket
     |> assign(:show_service_form, true)
     |> assign(:selected_company_id, company_id)
     |> assign(:service_form, to_form(%{}, as: "service"))}
  end

  @impl true
  def handle_event("cancel_add_product", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_product_form, false)
     |> assign(:selected_company_id, nil)
     |> assign(:product_form, to_form(%{}, as: "product"))}
  end

  @impl true
  def handle_event("cancel_add_service", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_service_form, false)
     |> assign(:selected_company_id, nil)
     |> assign(:service_form, to_form(%{}, as: "service"))}
  end

  @impl true
  def handle_event("validate_product", %{"product" => product_params}, socket) do
    company_id = socket.assigns[:selected_company_id]
    company = Enum.find(socket.assigns[:companies], &(&1.id == company_id))

    changeset =
      %Products.Product{}
      |> Products.Product.changeset(Map.merge(product_params, %{"company_id" => company.id}))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, product_form: to_form(changeset, as: "product"))}
  end

  @impl true
  def handle_event("validate_service", %{"service" => service_params}, socket) do
    company_id = socket.assigns[:selected_company_id]
    company = Enum.find(socket.assigns[:companies], &(&1.id == company_id))

    # Ensure all keys are strings for Ecto
    params_with_company =
      service_params
      |> Map.drop(["company_id"])
      |> Map.merge(%{"company_id" => company.id})

    changeset =
      %Services.Service{}
      |> Services.Service.changeset(params_with_company)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, service_form: to_form(changeset, as: "service"))}
  end

  @impl true
  def handle_event("add_product", %{"product" => product_params}, socket) do
    company_id = socket.assigns[:selected_company_id]
    company = Enum.find(socket.assigns[:companies], &(&1.id == company_id))

    # Remove company_id from params if it exists (create_product takes company as first arg)
    clean_params = Map.drop(product_params, ["company_id"])

    case Products.create_product(company, clean_params) do
      {:ok, _product} ->
        # Reload companies with updated data
        companies = get_user_companies(socket.assigns[:current_user])
        companies_with_data = load_companies_data(companies)

        {:noreply,
         socket
         |> assign(:companies, companies_with_data)
         |> assign(:show_product_form, false)
         |> assign(:selected_company_id, nil)
         |> assign(:product_form, to_form(%{}, as: "product"))
         |> put_flash(:info, "Product added successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, product_form: to_form(changeset, as: "product"))}
    end
  end

  @impl true
  def handle_event("add_service", %{"service" => service_params}, socket) do
    company_id = socket.assigns[:selected_company_id]
    company = Enum.find(socket.assigns[:companies], &(&1.id == company_id))

    case Services.create_service(company, service_params) do
      {:ok, _service} ->
        # Reload companies with updated data
        companies = get_user_companies(socket.assigns[:current_user])
        companies_with_data = load_companies_data(companies)

        {:noreply,
         socket
         |> assign(:companies, companies_with_data)
         |> assign(:show_service_form, false)
         |> assign(:selected_company_id, nil)
         |> assign(:service_form, to_form(%{}, as: "service"))
         |> put_flash(:info, "Service added successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, service_form: to_form(changeset, as: "service"))}
    end
  end

  defp project_status_badge(:active), do: "bg-green-100 text-green-800"
  defp project_status_badge(:paused), do: "bg-yellow-100 text-yellow-800"
  defp project_status_badge(:archived), do: "bg-gray-100 text-gray-800"

  defp confidence_color(confidence) when confidence >= 0.8, do: "text-green-600"
  defp confidence_color(confidence) when confidence >= 0.5, do: "text-yellow-600"
  defp confidence_color(_confidence), do: "text-red-600"

  defp has_chart_data?(companies) do
    Enum.any?(companies, fn company -> company.confidence_history != [] end)
  end

  defp format_chart_data(history) do
    labels =
      Enum.map(history, fn item ->
        item.date
        |> DateTime.to_date()
        |> Date.to_string()
      end)

    datasets = [
      %{
        label: "Confidence Score",
        data: Enum.map(history, &Float.round(&1.confidence * 100, 1)),
        borderColor: "rgb(59, 130, 246)",
        backgroundColor: "rgba(59, 130, 246, 0.1)",
        tension: 0.4
      }
    ]

    %{
      labels: labels,
      datasets: datasets
    }
  end
end

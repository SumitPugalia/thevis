defmodule ThevisWeb.ClientDashboardLive do
  @moduledoc """
  Client dashboard showing their company, products, and projects.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Products
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

      Map.merge(company, %{
        products: products,
        services: services,
        products_count: length(products),
        services_count: length(services)
      })
    end)
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
end

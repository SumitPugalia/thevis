defmodule ThevisWeb.ClientOnboardingLive do
  @moduledoc """
  LiveView for client onboarding - collecting company and product/service information.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    if current_user do
      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:step, 1)
       |> assign(:company, nil)
       |> assign(:products, [])
       |> assign(:form, to_form(%{}, as: "company"))}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: ~p"/login")}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Complete Your Profile")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <div class="mx-auto max-w-3xl">
        <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-8">
          <div class="mb-8">
            <h1 class="text-3xl font-bold text-gray-900">Complete Your Profile</h1>
            <p class="mt-2 text-sm text-gray-600">Tell us about your company to get started</p>
          </div>
          
    <!-- Progress Steps -->
          <div class="mb-8">
            <div class="flex items-center">
              <div class={"flex items-center #{if @step >= 1, do: "text-blue-600", else: "text-gray-400"}"}>
                <div class={"rounded-full w-10 h-10 flex items-center justify-center border-2 #{if @step >= 1, do: "border-blue-600 bg-blue-50", else: "border-gray-300"}"}>
                  <%= if @step > 1 do %>
                    <.icon name="hero-check" class="w-6 h-6" />
                  <% else %>
                    <span class="font-semibold">1</span>
                  <% end %>
                </div>
                <span class="ml-2 font-medium">Company Info</span>
              </div>
              <div class={"flex-1 h-0.5 mx-4 #{if @step >= 2, do: "bg-blue-600", else: "bg-gray-300"}"}>
              </div>
              <div class={"flex items-center #{if @step >= 2, do: "text-blue-600", else: "text-gray-400"}"}>
                <div class={"rounded-full w-10 h-10 flex items-center justify-center border-2 #{if @step >= 2, do: "border-blue-600 bg-blue-50", else: "border-gray-300"}"}>
                  <%= if @step > 2 do %>
                    <.icon name="hero-check" class="w-6 h-6" />
                  <% else %>
                    <span class="font-semibold">2</span>
                  <% end %>
                </div>
                <span class="ml-2 font-medium">Products/Services</span>
              </div>
              <div class={"flex-1 h-0.5 mx-4 #{if @step >= 3, do: "bg-blue-600", else: "bg-gray-300"}"}>
              </div>
              <div class={"flex items-center #{if @step >= 3, do: "text-blue-600", else: "text-gray-400"}"}>
                <div class={"rounded-full w-10 h-10 flex items-center justify-center border-2 #{if @step >= 3, do: "border-blue-600 bg-blue-50", else: "border-gray-300"}"}>
                  <span class="font-semibold">3</span>
                </div>
                <span class="ml-2 font-medium">Review</span>
              </div>
            </div>
          </div>
          
    <!-- Step 1: Company Information -->
          <%= if @step == 1 do %>
            <.form
              for={@form}
              id="company-form"
              phx-submit="save_company"
              phx-change="validate_company"
              class="space-y-6"
            >
              <.input
                field={@form[:name]}
                type="text"
                label="Company Name"
                required
                placeholder="Acme Inc."
              />
              <.input
                field={@form[:domain]}
                type="text"
                label="Company Domain"
                required
                placeholder="acme.com"
              />
              <.input
                field={@form[:industry]}
                type="text"
                label="Industry"
                required
                placeholder="Technology, Cosmetics, etc."
              />
              <.input
                field={@form[:website_url]}
                type="url"
                label="Website URL"
                placeholder="https://acme.com"
              />
              <.input
                field={@form[:description]}
                type="textarea"
                label="Company Description"
                placeholder="Brief description of your company"
              />
              <.input
                field={@form[:company_type]}
                type="select"
                label="Company Type"
                required
                options={[{"Product-Based", "product_based"}, {"Service-Based", "service_based"}]}
              />

              <div>
                <.button class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg">
                  Continue
                </.button>
              </div>
            </.form>
          <% end %>
          
    <!-- Step 2: Products/Services -->
          <%= if @step == 2 do %>
            <div class="space-y-6">
              <div>
                <h2 class="text-xl font-semibold text-gray-900 mb-4">
                  <%= if @company.company_type == :product_based do %>
                    Add Your Products
                  <% else %>
                    Service Information
                  <% end %>
                </h2>

                <%= if @company.company_type == :product_based do %>
                  <div id="products" phx-update="stream" class="space-y-4">
                    <div
                      :for={{id, product} <- @streams.products}
                      id={id}
                      class="bg-gray-50 p-4 rounded-lg"
                    >
                      <div class="flex justify-between items-start">
                        <div class="flex-1">
                          <h3 class="font-medium text-gray-900">{product.name}</h3>
                          <p class="text-sm text-gray-600">
                            {product.category} - {String.capitalize(to_string(product.product_type))}
                          </p>
                        </div>
                        <button
                          type="button"
                          phx-click="remove_product"
                          phx-value-id={id}
                          class="text-red-600 hover:text-red-900"
                        >
                          <.icon name="hero-trash" class="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  </div>

                  <button
                    type="button"
                    phx-click="show_add_product"
                    class="mt-4 w-full border-2 border-dashed border-gray-300 rounded-lg p-4 text-gray-600 hover:border-blue-500 hover:text-blue-600 transition-colors"
                  >
                    <.icon name="hero-plus" class="w-5 h-5 inline mr-2" /> Add Product
                  </button>
                <% else %>
                  <p class="text-sm text-gray-600">
                    Your company will be optimized as a service. You can add competitor companies if needed.
                  </p>
                <% end %>
              </div>

              <div class="flex gap-4">
                <.button
                  phx-click="previous_step"
                  class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 font-medium py-3 px-4 rounded-lg"
                >
                  Back
                </.button>
                <.button
                  phx-click="next_step"
                  class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg"
                >
                  Continue
                </.button>
              </div>
            </div>
          <% end %>
          
    <!-- Step 3: Review -->
          <%= if @step == 3 do %>
            <div class="space-y-6">
              <div>
                <h2 class="text-xl font-semibold text-gray-900 mb-4">Review Your Information</h2>

                <div class="bg-gray-50 p-6 rounded-lg space-y-4">
                  <div>
                    <h3 class="font-medium text-gray-900">Company</h3>
                    <p class="text-sm text-gray-600">{@company.name} ({@company.domain})</p>
                    <p class="text-sm text-gray-600">{@company.industry}</p>
                  </div>

                  <%= if @company.company_type == :product_based do %>
                    <div>
                      <h3 class="font-medium text-gray-900">Products</h3>
                      <p class="text-sm text-gray-600">
                        {length(@products)} product(s) added
                      </p>
                    </div>
                  <% end %>
                </div>
              </div>

              <div class="flex gap-4">
                <.button
                  phx-click="previous_step"
                  class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 font-medium py-3 px-4 rounded-lg"
                >
                  Back
                </.button>
                <.button
                  phx-click="complete_onboarding"
                  class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg"
                >
                  Complete Setup
                </.button>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate_company", %{"company" => company_params}, socket) do
    changeset =
      %Accounts.Company{}
      |> Accounts.Company.changeset(company_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save_company", %{"company" => company_params}, socket) do
    # Link company to current user
    current_user = socket.assigns[:current_user]

    case Accounts.create_company(company_params) do
      {:ok, company} ->
        # Assign role to link user to company
        Accounts.assign_role(current_user, company, :owner)

        {:noreply,
         socket
         |> assign(:company, company)
         |> assign(:step, 2)
         |> stream(:products, [], reset: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("show_add_product", _params, socket) do
    # This will be handled by a modal or separate form
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_product", %{"id" => id}, socket) do
    {:noreply, stream_delete(socket, :products, id)}
  end

  @impl true
  def handle_event("previous_step", _params, socket) do
    step = max(1, socket.assigns.step - 1)
    {:noreply, assign(socket, :step, step)}
  end

  @impl true
  def handle_event("next_step", _params, socket) do
    step = min(3, socket.assigns.step + 1)
    {:noreply, assign(socket, :step, step)}
  end

  @impl true
  def handle_event("complete_onboarding", _params, socket) do
    # Link company to user, create initial project, etc.
    {:noreply,
     socket
     |> put_flash(:info, "Onboarding completed successfully!")
     |> push_navigate(to: ~p"/dashboard")}
  end
end

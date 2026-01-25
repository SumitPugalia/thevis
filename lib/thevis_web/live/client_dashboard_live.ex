defmodule ThevisWeb.ClientDashboardLive do
  @moduledoc """
  Client dashboard showing their company, products, and projects.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    # current_user is now set by the on_mount hook
    current_user = socket.assigns[:current_user]

    if current_user do
      companies = get_user_companies(current_user)

      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:companies, companies)
       |> assign(:products, [])
       |> assign(:projects, [])}
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
    user
    |> Thevis.Repo.preload(:roles)
    |> Map.get(:roles, [])
    |> Enum.map(& &1.company_id)
    |> then(fn company_ids ->
      if Enum.empty?(company_ids) do
        []
      else
        Accounts.list_companies()
        |> Enum.filter(fn company -> company.id in company_ids end)
      end
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
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
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div
                :for={company <- @companies}
                class="border border-gray-200 rounded-lg p-4 hover:border-blue-500 transition-colors"
              >
                <h3 class="font-medium text-gray-900">{company.name}</h3>
                <p class="text-sm text-gray-600 mt-1">{company.domain}</p>
                <span class={"inline-flex items-center px-2 py-1 rounded-full text-xs font-medium mt-2 #{company_type_badge(company.company_type)}"}>
                  {String.replace(to_string(company.company_type), "_", " ") |> String.capitalize()}
                </span>
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
                <p class="text-2xl font-bold text-gray-900 mt-1">{length(@products)}</p>
              </div>
              <.icon name="hero-cube" class="w-8 h-8 text-purple-600" />
            </div>
          </div>

          <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Active Projects</p>
                <p class="text-2xl font-bold text-gray-900 mt-1">{length(@projects)}</p>
              </div>
              <.icon name="hero-chart-bar" class="w-8 h-8 text-green-600" />
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp company_type_badge(:product_based), do: "bg-blue-100 text-blue-800"
  defp company_type_badge(:service_based), do: "bg-purple-100 text-purple-800"
end

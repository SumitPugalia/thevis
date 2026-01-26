defmodule ThevisWeb.CompanyLive.Show do
  @moduledoc """
  LiveView for showing a single company.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    company = Accounts.get_company!(id)

    {:noreply,
     socket
     |> assign(:page_title, company.name)
     |> assign(:company, company)
     |> assign(:current_user, socket.assigns[:current_user])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} page_title={@page_title}>
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">{@company.name}</h1>
            <p class="mt-2 text-sm text-gray-600">{@company.domain}</p>
          </div>
          <.link
            navigate={~p"/companies/#{@company.id}/edit"}
            class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors"
          >
            <.icon name="hero-pencil" class="w-5 h-5" /> Edit
          </.link>
        </div>

        <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
          <dl class="grid grid-cols-1 gap-6 sm:grid-cols-2">
            <div>
              <dt class="text-sm font-medium text-gray-500">Industry</dt>
              <dd class="mt-1 text-sm text-gray-900">{@company.industry}</dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Company Type</dt>
              <dd class="mt-1">
                <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{company_type_badge(@company.company_type)}"}>
                  {String.replace(to_string(@company.company_type), "_", " ") |> String.capitalize()}
                </span>
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Website</dt>
              <dd class="mt-1 text-sm text-gray-900">
                <%= if @company.website_url do %>
                  <a
                    href={@company.website_url}
                    target="_blank"
                    class="text-blue-600 hover:text-blue-900"
                  >
                    {@company.website_url}
                  </a>
                <% else %>
                  <span class="text-gray-400">-</span>
                <% end %>
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Description</dt>
              <dd class="mt-1 text-sm text-gray-900">{@company.description || "-"}</dd>
            </div>
          </dl>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp company_type_badge(:product_based), do: "bg-blue-100 text-blue-800"
  defp company_type_badge(:service_based), do: "bg-purple-100 text-purple-800"
end

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
  def handle_params(%{"id" => id}, url, socket) do
    company = Accounts.get_company!(id)

    path =
      if url do
        parsed =
          url
          |> to_string()
          |> URI.parse()
        parsed.path || ""
      else
        ""
      end

    is_admin_route = String.starts_with?(path, "/admin")

    {:noreply,
     socket
     |> assign(:page_title, company.name)
     |> assign(:company, company)
     |> assign(:current_user, socket.assigns[:current_user])
     |> assign(:is_admin_route, is_admin_route)}
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
            navigate={
              if @is_admin_route,
                do: ~p"/admin/companies/#{@company.id}/edit",
                else: ~p"/companies/#{@company.id}/edit"
            }
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
                <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{BadgeHelpers.company_type_badge(@company.company_type)}"}>
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
            <div class="sm:col-span-2">
              <dt class="text-sm font-medium text-gray-500">Description</dt>
              <dd class="mt-1 text-sm text-gray-900">{@company.description || "-"}</dd>
            </div>
            <%= if @company.category || @company.one_line_definition || @company.problem_solved || @company.key_concepts do %>
              <div class="sm:col-span-2 border-t border-gray-200 pt-6 mt-2">
                <h3 class="text-sm font-semibold text-gray-900 mb-3">
                  Entity block (for AI visibility)
                </h3>
                <dl class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <%= if @company.category do %>
                    <div>
                      <dt class="text-sm font-medium text-gray-500">Category</dt>
                      <dd class="mt-1 text-sm text-gray-900">{@company.category}</dd>
                    </div>
                  <% end %>
                  <%= if @company.one_line_definition do %>
                    <div class="sm:col-span-2">
                      <dt class="text-sm font-medium text-gray-500">One-line definition</dt>
                      <dd class="mt-1 text-sm text-gray-900">{@company.one_line_definition}</dd>
                    </div>
                  <% end %>
                  <%= if @company.problem_solved do %>
                    <div class="sm:col-span-2">
                      <dt class="text-sm font-medium text-gray-500">Primary problem solved</dt>
                      <dd class="mt-1 text-sm text-gray-900">{@company.problem_solved}</dd>
                    </div>
                  <% end %>
                  <%= if @company.key_concepts do %>
                    <div>
                      <dt class="text-sm font-medium text-gray-500">Key concepts</dt>
                      <dd class="mt-1 text-sm text-gray-900">{@company.key_concepts}</dd>
                    </div>
                  <% end %>
                </dl>
              </div>
            <% end %>
          </dl>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

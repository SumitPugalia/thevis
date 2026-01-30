defmodule ThevisWeb.ProjectLive.Show do
  @moduledoc """
  LiveView for showing a single project.
  """

  use ThevisWeb, :live_view

  alias Thevis.Projects
  alias Thevis.Scans

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    project =
      id
      |> Projects.get_project!()
      |> Thevis.Repo.preload(:product)

    geo_metrics = Scans.get_geo_metrics(project)

    {:noreply,
     socket
     |> assign(:page_title, project.name)
     |> assign(:project, project)
     |> assign(:geo_metrics, geo_metrics)
     |> assign(:current_user, socket.assigns[:current_user])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} page_title={@page_title}>
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">{@project.name}</h1>
            <p class="mt-2 text-sm text-gray-600">{@project.description || "-"}</p>
          </div>
          <div class="flex gap-3">
            <.link
              navigate={~p"/projects/#{@project.id}/scans"}
              class="inline-flex items-center gap-2 px-4 py-2 bg-purple-600 text-white font-medium rounded-lg hover:bg-purple-700 transition-colors"
            >
              <.icon name="hero-magnifying-glass" class="w-5 h-5" /> View Scans
            </.link>
            <%= if @geo_metrics do %>
              <a
                href={~p"/projects/#{@project.id}/report"}
                download
                class="inline-flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white font-medium rounded-lg hover:bg-emerald-700 transition-colors"
              >
                <.icon name="hero-document-arrow-down" class="w-5 h-5" /> Export PDF Report
              </a>
            <% end %>
            <.link
              navigate={~p"/projects/#{@project.id}/edit"}
              class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors"
            >
              <.icon name="hero-pencil" class="w-5 h-5" /> Edit
            </.link>
          </div>
        </div>

        <%= if @geo_metrics do %>
          <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">GEO Audit Summary</h2>
            <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
              <div class="rounded-lg bg-gray-50 p-4">
                <p class="text-sm font-medium text-gray-500">GEO Score</p>
                <p class={"mt-1 text-2xl font-bold #{geo_score_text_class(@geo_metrics.geo_score)}"}>
                  {Float.round(@geo_metrics.geo_score, 1)}/100
                </p>
              </div>
              <div class="rounded-lg bg-gray-50 p-4">
                <p class="text-sm font-medium text-gray-500">Recall %</p>
                <p class="mt-1 text-2xl font-bold text-gray-900">
                  {Float.round(@geo_metrics.recall_percentage, 1)}%
                </p>
              </div>
              <div class="rounded-lg bg-gray-50 p-4">
                <p class="text-sm font-medium text-gray-500">First Mention Rank</p>
                <p class="mt-1 text-2xl font-bold text-gray-900">
                  {if @geo_metrics.avg_mention_rank,
                    do: Float.round(@geo_metrics.avg_mention_rank, 1),
                    else: "—"}
                </p>
              </div>
            </div>
          </div>
        <% end %>

        <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
          <dl class="grid grid-cols-1 gap-6 sm:grid-cols-2">
            <div>
              <dt class="text-sm font-medium text-gray-500">Project Type</dt>
              <dd class="mt-1">
                <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{BadgeHelpers.project_type_badge(@project.project_type)}"}>
                  {String.replace(to_string(@project.project_type), "_", " ") |> String.capitalize()}
                </span>
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Status</dt>
              <dd class="mt-1">
                <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{BadgeHelpers.project_status_badge(@project.status)}"}>
                  {String.capitalize(to_string(@project.status))}
                </span>
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Product</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {if @project.product, do: @project.product.name, else: "-"}
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Scan Frequency</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {String.capitalize(to_string(@project.scan_frequency))}
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Urgency Level</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {String.capitalize(to_string(@project.urgency_level))}
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Category Project</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {if @project.is_category_project, do: "Yes", else: "No"}
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp geo_score_text_class(score) when score >= 80, do: "text-green-600"
  defp geo_score_text_class(score) when score >= 60, do: "text-green-500"
  defp geo_score_text_class(score) when score >= 40, do: "text-yellow-600"
  defp geo_score_text_class(_score), do: "text-red-600"
end

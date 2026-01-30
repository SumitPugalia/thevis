defmodule ThevisWeb.ScanLive.Show do
  @moduledoc """
  LiveView for showing scan details and entity snapshots.
  """

  use ThevisWeb, :live_view

  alias Thevis.Geo
  alias Thevis.Geo.RecallScorer
  alias Thevis.Projects
  alias Thevis.Scans

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => project_id, "scan_run_id" => scan_run_id}, _url, socket) do
    project = Projects.get_project!(project_id)
    scan_run = Scans.get_scan_run!(scan_run_id)
    snapshots = Geo.list_entity_snapshots(scan_run)
    recall_results = Geo.list_recall_results(scan_run)

    {:noreply,
     socket
     |> assign(:page_title, "Scan Details - #{project.name}")
     |> assign(:project, project)
     |> assign(:scan_run, scan_run)
     |> assign(:current_user, socket.assigns[:current_user])
     |> assign(:snapshots, snapshots)
     |> assign(:recall_results, recall_results)}
  end

  defp confidence_color(confidence) when confidence >= 0.8, do: "text-green-600"
  defp confidence_color(confidence) when confidence >= 0.5, do: "text-yellow-600"
  defp confidence_color(_confidence), do: "text-red-600"

  defp confidence_bar_width(confidence) do
    "#{Float.round(confidence * 100, 1)}%"
  end

  defp calculate_recall_percentage(results) do
    results
    |> Enum.map(fn result -> %{mentioned: result.mentioned} end)
    |> RecallScorer.calculate_recall_percentage()
  end

  defp calculate_mention_rank(results) do
    results
    |> Enum.map(fn result ->
      %{mentioned: result.mentioned, mention_rank: result.mention_rank}
    end)
    |> RecallScorer.calculate_first_mention_rank()
  end
end

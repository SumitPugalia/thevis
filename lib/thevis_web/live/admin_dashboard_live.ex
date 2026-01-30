defmodule ThevisWeb.AdminDashboardLive do
  @moduledoc """
  Admin Dashboard LiveView for consultants/admins.

  Shows overview of all companies, projects, and system metrics.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Automation
  alias Thevis.Geo
  alias Thevis.Geo.RecallScorer
  alias Thevis.Projects
  alias Thevis.Scans
  alias Thevis.Strategy
  alias Thevis.Wikis

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "Admin Dashboard")
     |> load_admin_data()}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp load_admin_data(socket) do
    companies = Accounts.list_companies()
    projects = Projects.list_all_projects()
    recent_scans = get_recent_scans()
    strategy_stats = get_strategy_stats(projects)
    wiki_stats = get_wiki_stats(projects)
    task_stats = get_task_stats(projects)
    campaign_stats = get_campaign_stats(projects)
    client_scan_results = get_client_scan_results(companies)

    socket
    |> assign(:companies, companies)
    |> assign(:projects, projects)
    |> assign(:recent_scans, recent_scans)
    |> assign(:client_scan_results, client_scan_results)
    |> assign(
      :stats,
      calculate_stats(
        companies,
        projects,
        recent_scans,
        strategy_stats,
        wiki_stats,
        task_stats,
        campaign_stats
      )
    )
    |> assign(:strategy_stats, strategy_stats)
    |> assign(:wiki_stats, wiki_stats)
    |> assign(:task_stats, task_stats)
    |> assign(:campaign_stats, campaign_stats)
  end

  defp get_client_scan_results(companies) do
    Enum.flat_map(companies, fn company ->
      projects = Projects.list_projects_by_company(company)
      Enum.map(projects, &build_client_scan_result(company, &1))
    end)
  end

  defp build_client_scan_result(company, project) do
    latest_scan = Scans.get_latest_scan_run(project)
    result_summary = if latest_scan, do: scan_result_summary(latest_scan), else: nil

    %{
      company: company,
      project: project,
      product: project.product,
      latest_scan_run: latest_scan,
      result_summary: result_summary
    }
  end

  defp scan_result_summary(%Scans.ScanRun{} = scan_run) do
    case scan_run.scan_type do
      :recall ->
        results = Geo.list_recall_results(scan_run)

        pct =
          results
          |> Enum.map(&%{mentioned: &1.mentioned})
          |> RecallScorer.calculate_recall_percentage()

        %{type: :recall, recall_pct: pct}

      :entity_probe ->
        confidence = entity_probe_confidence(scan_run)
        %{type: :entity_probe, confidence: confidence}

      _ ->
        %{type: scan_run.scan_type}
    end
  end

  defp entity_probe_confidence(scan_run) do
    snapshots = Geo.list_entity_snapshots(scan_run)

    if Enum.empty?(snapshots) do
      nil
    else
      sum = Enum.reduce(snapshots, 0, fn s, acc -> acc + s.confidence_score end)
      sum / length(snapshots)
    end
  end

  defp get_recent_scans do
    # Get recent scans across all projects
    all_projects = Projects.list_all_projects()

    scan_runs =
      Enum.flat_map(all_projects, fn project ->
        project_scans = Scans.list_scan_runs(project)
        Enum.take(project_scans, 5)
      end)

    sorted_scans =
      Enum.sort_by(scan_runs, & &1.inserted_at, {:desc, DateTime})

    top_10_scans = Enum.take(sorted_scans, 10)

    Enum.map(top_10_scans, fn scan ->
      Thevis.Repo.preload(scan, :project)
    end)
  end

  defp calculate_stats(
         companies,
         projects,
         recent_scans,
         strategy_stats,
         wiki_stats,
         task_stats,
         campaign_stats
       ) do
    %{
      total_companies: length(companies),
      total_projects: length(projects),
      active_projects: Enum.count(projects, fn project -> project.status == :active end),
      total_scans: length(recent_scans),
      completed_scans: Enum.count(recent_scans, fn scan -> scan.status == :completed end),
      total_tasks: task_stats.total_tasks,
      pending_tasks: task_stats.pending_tasks,
      total_playbooks: strategy_stats.total_playbooks,
      total_narratives: strategy_stats.total_narratives,
      total_wiki_pages: wiki_stats.total_wiki_pages,
      published_wiki_pages: wiki_stats.published_wiki_pages,
      total_campaigns: campaign_stats.total_campaigns,
      active_campaigns: campaign_stats.active_campaigns,
      total_content_items: campaign_stats.total_content_items
    }
  end

  defp get_strategy_stats(projects) do
    all_playbooks = Strategy.list_playbooks()

    all_narratives =
      Enum.flat_map(projects, fn project -> Strategy.list_narratives(project.id) end)

    %{
      total_playbooks: length(all_playbooks),
      template_playbooks: Enum.count(all_playbooks, & &1.is_template),
      total_narratives: length(all_narratives),
      active_narratives: Enum.count(all_narratives, & &1.is_active)
    }
  end

  defp get_wiki_stats(projects) do
    all_wiki_pages = Enum.flat_map(projects, fn project -> Wikis.list_wiki_pages(project.id) end)

    %{
      total_wiki_pages: length(all_wiki_pages),
      published_wiki_pages: Enum.count(all_wiki_pages, fn page -> page.status == :published end),
      draft_wiki_pages: Enum.count(all_wiki_pages, fn page -> page.status == :draft end),
      total_platforms: length(Wikis.list_wiki_platforms())
    }
  end

  defp get_task_stats(projects) do
    all_tasks = Enum.flat_map(projects, fn project -> Strategy.list_tasks(project.id) end)

    %{
      total_tasks: length(all_tasks),
      pending_tasks: Enum.count(all_tasks, fn task -> task.status == :pending end),
      in_progress_tasks: Enum.count(all_tasks, fn task -> task.status == :in_progress end),
      completed_tasks: Enum.count(all_tasks, fn task -> task.status == :completed end)
    }
  end

  defp get_campaign_stats(projects) do
    all_campaigns =
      Enum.flat_map(projects, fn project ->
        Automation.list_campaigns(project.id)
      end)

    all_content_items =
      Enum.flat_map(all_campaigns, fn campaign ->
        Automation.list_content_items(campaign.id)
      end)

    %{
      total_campaigns: length(all_campaigns),
      active_campaigns: Enum.count(all_campaigns, fn campaign -> campaign.status == :active end),
      total_content_items: length(all_content_items),
      published_content_items:
        Enum.count(all_content_items, fn item -> item.status == :published end)
    }
  end

  def result_summary_display(nil), do: nil

  def result_summary_display(%{type: :recall, recall_pct: pct}),
    do: "#{Float.round(pct, 1)}% recall"

  def result_summary_display(%{type: :entity_probe, confidence: conf}) when is_number(conf),
    do: "#{Float.round(conf * 100, 1)}% confidence"

  def result_summary_display(_), do: nil
end

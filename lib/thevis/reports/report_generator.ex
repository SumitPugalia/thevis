defmodule Thevis.Reports.ReportGenerator do
  @moduledoc """
  PDF report generation module for GEO audit reports.

  Generates comprehensive PDF reports containing:
  - Executive summary
  - GEO Score and metrics
  - Entity recognition details
  - Recall test results
  - Historical trends
  - Recommendations
  """

  import Ecto.Query
  alias Thevis.Geo
  alias Thevis.Projects.Project
  alias Thevis.Repo
  alias Thevis.Reports.GeoScore
  alias Thevis.Scans.ScanRun

  @doc """
  Generates a PDF report for a project's latest scan run.

  ## Parameters
  - `project`: The Project struct
  - `scan_run_id`: Optional scan run ID (uses latest if not provided)

  ## Returns
  `{:ok, binary}` - PDF binary data
  `{:error, reason}` - Error tuple

  ## Examples

      iex> generate_report(project)
      {:ok, <<...>>}

      iex> generate_report(project, scan_run_id)
      {:ok, <<...>>}

  """
  @spec generate_report(Project.t(), binary() | nil) :: {:ok, binary()} | {:error, atom()}
  def generate_report(%Project{} = project, scan_run_id \\ nil) do
    scan_run = get_scan_run(project, scan_run_id)

    if scan_run do
      report_data = collect_report_data(project, scan_run)
      html_content = generate_html_report(report_data)
      generate_pdf(html_content)
    else
      {:error, :no_scan_run}
    end
  end

  # Get scan run (latest if not specified) - preload project to avoid N+1
  defp get_scan_run(%Project{} = project, nil) do
    scan_run =
      ScanRun
      |> where([s], s.project_id == ^project.id)
      |> where([s], s.status == :completed)
      |> order_by([s], desc: s.completed_at)
      |> limit(1)
      |> Repo.one()

    case scan_run do
      nil -> nil
      found_scan_run -> Repo.preload(found_scan_run, :project)
    end
  end

  defp get_scan_run(%Project{} = project, scan_run_id) when not is_nil(scan_run_id) do
    scan_run =
      ScanRun
      |> where([s], s.project_id == ^project.id)
      |> where([s], s.id == ^scan_run_id)
      |> Repo.one()

    case scan_run do
      nil -> nil
      found_scan_run -> Repo.preload(found_scan_run, :project)
    end
  end

  # Collect all data needed for the report (with proper preloading to avoid N+1)
  defp collect_report_data(project, scan_run) do
    # Preload all associations in one query to avoid N+1
    project_with_associations = Repo.preload(project, product: :company)

    product = project_with_associations.product
    company = product.company

    # Get entity snapshot for this scan run (preload scan_run)
    snapshots = Geo.list_entity_snapshots(scan_run)
    first_snapshot = List.first(snapshots)

    entity_snapshot =
      case first_snapshot do
        nil -> nil
        snapshot -> Repo.preload(snapshot, :scan_run)
      end

    # Get recall results (already loaded, no additional queries needed)
    recall_results = Geo.list_recall_results(scan_run)

    # Calculate GEO Score
    geo_score = GeoScore.calculate_geo_score(entity_snapshot, recall_results)

    # Calculate recall metrics
    recall_percentage = Thevis.Geo.RecallScorer.calculate_recall_percentage(recall_results)
    avg_mention_rank = Thevis.Geo.RecallScorer.calculate_first_mention_rank(recall_results)

    # Get historical scan runs for trends (preload project to avoid N+1)
    historical_scans =
      ScanRun
      |> where([s], s.project_id == ^project.id)
      |> where([s], s.status == :completed)
      |> order_by([s], desc: s.completed_at)
      |> limit(10)
      |> Repo.all()
      |> Repo.preload(:project)

    %{
      company: company,
      product: product,
      project: project_with_associations,
      scan_run: scan_run,
      entity_snapshot: entity_snapshot,
      recall_results: recall_results,
      geo_score: geo_score,
      recall_percentage: recall_percentage,
      avg_mention_rank: avg_mention_rank,
      historical_scans: historical_scans,
      generated_at: DateTime.utc_now()
    }
  end

  # Generate HTML content for the report
  defp generate_html_report(data) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>GEO Audit Report - #{data.product.name}</title>
      <style>
        body {
          font-family: 'Helvetica Neue', Arial, sans-serif;
          margin: 40px;
          color: #333;
          line-height: 1.6;
        }
        .header {
          border-bottom: 3px solid #2563eb;
          padding-bottom: 20px;
          margin-bottom: 30px;
        }
        .header h1 {
          color: #2563eb;
          margin: 0;
          font-size: 32px;
        }
        .header .subtitle {
          color: #666;
          font-size: 14px;
          margin-top: 5px;
        }
        .section {
          margin-bottom: 40px;
        }
        .section h2 {
          color: #1e40af;
          border-bottom: 2px solid #e5e7eb;
          padding-bottom: 10px;
          margin-bottom: 20px;
        }
        .metric-card {
          background: #f8fafc;
          border: 1px solid #e2e8f0;
          border-radius: 8px;
          padding: 20px;
          margin-bottom: 20px;
        }
        .metric-label {
          font-size: 14px;
          color: #64748b;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          margin-bottom: 5px;
        }
        .metric-value {
          font-size: 36px;
          font-weight: bold;
          color: #1e293b;
        }
        .score-excellent { color: #10b981; }
        .score-good { color: #3b82f6; }
        .score-fair { color: #f59e0b; }
        .score-poor { color: #ef4444; }
        table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 20px;
        }
        th, td {
          padding: 12px;
          text-align: left;
          border-bottom: 1px solid #e5e7eb;
        }
        th {
          background: #f1f5f9;
          font-weight: 600;
          color: #475569;
        }
        .badge {
          display: inline-block;
          padding: 4px 12px;
          border-radius: 12px;
          font-size: 12px;
          font-weight: 600;
        }
        .badge-success { background: #d1fae5; color: #065f46; }
        .badge-warning { background: #fef3c7; color: #92400e; }
        .badge-danger { background: #fee2e2; color: #991b1b; }
        .footer {
          margin-top: 60px;
          padding-top: 20px;
          border-top: 1px solid #e5e7eb;
          font-size: 12px;
          color: #94a3b8;
          text-align: center;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>GEO Audit Report</h1>
        <div class="subtitle">
          #{data.product.name} | #{data.company.name} | Generated #{format_date(data.generated_at)}
        </div>
      </div>

      <div class="section">
        <h2>Executive Summary</h2>
        <p>
          This report presents the AI visibility analysis for <strong>#{data.product.name}</strong>
          from <strong>#{data.company.name}</strong>. The analysis was conducted on
          #{format_date(data.scan_run.completed_at)} and includes entity recognition,
          recall testing, and visibility metrics.
        </p>
      </div>

      <div class="section">
        <h2>GEO Score</h2>
        <div class="metric-card">
          <div class="metric-label">Overall GEO Score</div>
          <div class="metric-value #{score_class(data.geo_score)}">#{Float.round(data.geo_score, 1)}</div>
          <p style="margin-top: 10px; color: #64748b;">
            #{score_description(data.geo_score)}
          </p>
        </div>
      </div>

      <div class="section">
        <h2>Key Metrics</h2>
        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px;">
          <div class="metric-card">
            <div class="metric-label">Recognition Confidence</div>
            <div class="metric-value">
              #{if data.entity_snapshot && data.entity_snapshot.confidence_score, do: Float.round(data.entity_snapshot.confidence_score * 100, 1), else: "N/A"}%
            </div>
          </div>
          <div class="metric-card">
            <div class="metric-label">Recall Percentage</div>
            <div class="metric-value">#{Float.round(data.recall_percentage, 1)}%</div>
          </div>
          <div class="metric-card">
            <div class="metric-label">Average Mention Rank</div>
            <div class="metric-value">
              #{if data.avg_mention_rank, do: Float.round(data.avg_mention_rank, 1), else: "N/A"}
            </div>
          </div>
          <div class="metric-card">
            <div class="metric-label">Entity Recognized</div>
            <div class="metric-value">
              #{if data.entity_snapshot, do: "Yes", else: "No"}
            </div>
          </div>
        </div>
      </div>

      #{if data.entity_snapshot do
      """
      <div class="section">
        <h2>Entity Recognition Details</h2>
        <p>
          <strong>Status:</strong> Recognized<br>
          <strong>Confidence:</strong> #{if data.entity_snapshot.confidence_score, do: Float.round(data.entity_snapshot.confidence_score * 100, 1), else: "N/A"}%<br>
          <strong>AI Model:</strong> #{data.entity_snapshot.source_llm || "N/A"}<br>
          <strong>Description:</strong> #{format_description(data.entity_snapshot.ai_description)}
        </p>
      </div>
      """
    else
      """
      <div class="section">
        <h2>Entity Recognition Details</h2>
        <p>No entity recognition data available for this scan.</p>
      </div>
      """
    end}

      #{if data.recall_results != [] do
      """
      <div class="section">
        <h2>Recall Test Results</h2>
        <table>
          <thead>
            <tr>
              <th>Prompt Category</th>
              <th>Mentioned</th>
              <th>Mention Rank</th>
            </tr>
          </thead>
          <tbody>
            #{Enum.map_join(data.recall_results, &format_recall_result/1)}
          </tbody>
        </table>
      </div>
      """
    else
      """
      <div class="section">
        <h2>Recall Test Results</h2>
        <p>No recall test results available for this scan.</p>
      </div>
      """
    end}

      #{if length(data.historical_scans) > 1 do
      """
      <div class="section">
        <h2>Historical Trends</h2>
        <p>
          This project has #{length(data.historical_scans)} completed scans.
          Historical data shows trends in AI visibility over time.
        </p>
      </div>
      """
    else
      ""
    end}

      <div class="section">
        <h2>Recommendations</h2>
        <ul>
          #{Enum.map_join(generate_recommendations(data), &"<li>#{&1}</li>")}
        </ul>
      </div>

      <div class="footer">
        <p>Generated by thevis.ai | #{format_date(data.generated_at)}</p>
        <p>This report is confidential and intended for internal use only.</p>
      </div>
    </body>
    </html>
    """
  end

  # Generate PDF from HTML
  defp generate_pdf(html_content) do
    case PdfGenerator.generate(html_content,
           page_size: "A4",
           margin: %{top: 20, bottom: 20, left: 20, right: 20}
         ) do
      {:ok, pdf} -> {:ok, pdf}
      {:error, reason} -> {:error, reason}
    end
  end

  # Helper functions
  defp format_date(%DateTime{} = dt) do
    Calendar.strftime(dt, "%B %d, %Y at %I:%M %p UTC")
  end

  defp score_class(score) when score >= 80, do: "score-excellent"
  defp score_class(score) when score >= 60, do: "score-good"
  defp score_class(score) when score >= 40, do: "score-fair"
  defp score_class(_score), do: "score-poor"

  defp score_description(score) when score >= 80,
    do: "Excellent AI visibility. Product is well-recognized and frequently mentioned."

  defp score_description(score) when score >= 60,
    do: "Good AI visibility. Product recognition is solid with room for improvement."

  defp score_description(score) when score >= 40,
    do: "Fair AI visibility. Product needs optimization to improve recognition."

  defp score_description(_score),
    do: "Poor AI visibility. Significant optimization needed to improve recognition."

  defp generate_recommendations(data) do
    recommendations = build_recommendations(data, [])

    if Enum.empty?(recommendations) do
      ["Continue monitoring and maintain current optimization efforts."]
    else
      recommendations
    end
  end

  defp build_recommendations(data, acc) do
    acc
    |> add_geo_score_recommendation(data.geo_score)
    |> add_recall_recommendation(data.recall_percentage)
    |> add_mention_rank_recommendation(data.avg_mention_rank)
    |> add_entity_snapshot_recommendation(data.entity_snapshot)
  end

  defp add_geo_score_recommendation(acc, geo_score) when geo_score < 40 do
    [
      "Focus on improving entity recognition through better product descriptions and documentation.",
      "Increase content creation and distribution to improve AI training signals."
      | acc
    ]
  end

  defp add_geo_score_recommendation(acc, _geo_score), do: acc

  defp add_recall_recommendation(acc, recall_percentage) when recall_percentage < 50 do
    [
      "Improve recall by optimizing product descriptions and ensuring consistent messaging across platforms."
      | acc
    ]
  end

  defp add_recall_recommendation(acc, _recall_percentage), do: acc

  defp add_mention_rank_recommendation(acc, avg_mention_rank)
       when not is_nil(avg_mention_rank) and avg_mention_rank > 3 do
    [
      "Work on improving mention rank by enhancing product visibility and authority."
      | acc
    ]
  end

  defp add_mention_rank_recommendation(acc, _avg_mention_rank), do: acc

  defp add_entity_snapshot_recommendation(acc, nil) do
    [
      "Entity recognition data not available. Run an entity probe scan to gather recognition data."
      | acc
    ]
  end

  defp add_entity_snapshot_recommendation(acc, _entity_snapshot), do: acc

  defp format_description(description) when is_binary(description) do
    truncated = String.slice(description, 0..200)

    if String.length(description) > 200 do
      truncated <> "..."
    else
      truncated
    end
  end

  defp format_recall_result(result) do
    category_display =
      result.prompt_category
      |> String.replace("_", " ")
      |> String.split(" ")
      |> Enum.map_join(" ", &String.capitalize/1)

    badge_class = if result.mentioned, do: "badge-success", else: "badge-danger"
    mentioned_text = if result.mentioned, do: "Yes", else: "No"
    rank_text = if result.mention_rank, do: result.mention_rank, else: "N/A"

    """
    <tr>
      <td>#{category_display}</td>
      <td>
        <span class="badge #{badge_class}">
          #{mentioned_text}
        </span>
      </td>
      <td>#{rank_text}</td>
    </tr>
    """
  end
end

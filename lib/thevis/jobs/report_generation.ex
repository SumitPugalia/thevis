defmodule Thevis.Jobs.ReportGeneration do
  @moduledoc """
  Background job for generating PDF reports.
  """

  use Oban.Worker, queue: :reports, max_attempts: 2

  alias Thevis.Projects
  alias Thevis.Reports.ReportGenerator

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"project_id" => project_id, "scan_run_id" => scan_run_id}}) do
    project = Projects.get_project(project_id)

    if project do
      case ReportGenerator.generate_report(project, scan_run_id) do
        {:ok, _pdf_data} ->
          :ok

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :project_not_found}
    end
  end
end

defmodule Thevis.Jobs.ScanExecution do
  @moduledoc """
  Background job for executing scans asynchronously.
  Can execute a specific scan run or create and execute a new scan for a project.
  """

  use Oban.Worker, queue: :scans, max_attempts: 3

  alias Thevis.Projects
  alias Thevis.Scans

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    cond do
      Map.has_key?(args, "scan_run_id") ->
        execute_existing_scan(args["scan_run_id"])

      Map.has_key?(args, "project_id") ->
        create_and_execute_scan(args)

      true ->
        {:error, :invalid_args}
    end
  end

  defp execute_existing_scan(scan_run_id) do
    scan_run = Scans.get_scan_run(scan_run_id)

    if scan_run do
      case Scans.execute_scan(scan_run) do
        {:ok, _result} -> :ok
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :scan_run_not_found}
    end
  end

  defp create_and_execute_scan(%{"project_id" => project_id, "scan_type" => scan_type_str}) do
    project = Projects.get_project(project_id)

    if project && project.status == :active do
      scan_type = String.to_existing_atom(scan_type_str)

      case Scans.create_scan_run(project, %{scan_type: scan_type}) do
        {:ok, scan_run} -> execute_scan_run(scan_run)
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, :project_not_found_or_inactive}
    end
  end

  defp execute_scan_run(scan_run) do
    case Scans.execute_scan(scan_run) do
      {:ok, _result} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end

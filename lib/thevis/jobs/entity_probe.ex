defmodule Thevis.Jobs.EntityProbe do
  @moduledoc """
  Background job for executing entity probe scans.
  """

  use Oban.Worker, queue: :scans, max_attempts: 3

  alias Thevis.Scans

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"scan_run_id" => scan_run_id}}) do
    scan_run = Scans.get_scan_run(scan_run_id)

    if scan_run && scan_run.scan_type == :entity_probe do
      case Scans.execute_scan(scan_run) do
        {:ok, _result} ->
          :ok

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :invalid_scan_type}
    end
  end
end

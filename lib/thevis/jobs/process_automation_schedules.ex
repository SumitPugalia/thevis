defmodule Thevis.Jobs.ProcessAutomationSchedules do
  @moduledoc """
  Periodic Oban worker that processes due automation schedules (baseline scan,
  recurring scan) and reschedules itself to run again in 10 minutes.
  """

  use Oban.Worker,
    queue: :default,
    max_attempts: 1,
    unique: [period: 600, states: [:available, :scheduled, :executing]]

  @interval_seconds 600

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    processed = Thevis.Automation.Schedules.process_due_schedules()
    reschedule_self()
    {:ok, %{processed: processed}}
  end

  defp reschedule_self do
    %{}
    |> __MODULE__.new(schedule_in: @interval_seconds)
    |> Oban.insert()
  end
end

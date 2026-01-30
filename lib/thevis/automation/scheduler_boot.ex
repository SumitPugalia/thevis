defmodule Thevis.Automation.SchedulerBoot do
  @moduledoc """
  One-shot process that inserts the first ProcessAutomationSchedules job on app start
  so the 10-minute automation schedule processor runs periodically.
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    Process.send_after(self(), :bootstrap, 2_000)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:bootstrap, state) do
    %{}
    |> Thevis.Jobs.ProcessAutomationSchedules.new(schedule_in: 60)
    |> Oban.insert()

    {:stop, :normal, state}
  end
end

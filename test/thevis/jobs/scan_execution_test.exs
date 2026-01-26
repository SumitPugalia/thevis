defmodule Thevis.Jobs.ScanExecutionTest do
  @moduledoc """
  Tests for ScanExecution background job.
  """

  use Thevis.DataCase
  import Mox

  alias Thevis.Jobs.ScanExecution
  alias Thevis.Scans

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "perform/1" do
    setup do
      project = insert(:product_project)
      {:ok, project: project}
    end

    test "executes an existing scan run", %{project: project} do
      {:ok, scan_run} = Scans.create_scan_run(project, %{scan_type: :entity_probe})

      # Mock AI adapter - EntityProbe calls chat_completion once
      expect(Thevis.AI.MockAdapter, :chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "#{project.product.name} is a great product."
               }
             }
           ],
           "model" => "gpt-4o-mini"
         }}
      end)

      assert :ok = ScanExecution.perform(%Oban.Job{args: %{"scan_run_id" => scan_run.id}})

      # Verify scan was executed
      updated_scan_run = Scans.get_scan_run!(scan_run.id)
      assert updated_scan_run.status == :completed
    end

    test "creates and executes a new scan for a project", %{project: project} do
      # Mock AI adapter - EntityProbe calls chat_completion once
      expect(Thevis.AI.MockAdapter, :chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "#{project.product.name} is a great product."
               }
             }
           ],
           "model" => "gpt-4o-mini"
         }}
      end)

      assert :ok =
               ScanExecution.perform(%Oban.Job{
                 args: %{"project_id" => project.id, "scan_type" => "entity_probe"}
               })

      # Verify scan was created and executed
      scan_runs = Scans.list_scan_runs(project)
      assert length(scan_runs) == 1
      assert hd(scan_runs).status == :completed
    end

    test "returns error for invalid scan_run_id" do
      assert {:error, :scan_run_not_found} =
               ScanExecution.perform(%Oban.Job{args: %{"scan_run_id" => Ecto.UUID.generate()}})
    end

    test "returns error for invalid project_id" do
      assert {:error, :project_not_found_or_inactive} =
               ScanExecution.perform(%Oban.Job{
                 args: %{"project_id" => Ecto.UUID.generate(), "scan_type" => "entity_probe"}
               })
    end

    test "returns error for invalid args" do
      assert {:error, :invalid_args} = ScanExecution.perform(%Oban.Job{args: %{}})
    end
  end
end

defmodule Thevis.ScansTest do
  use Thevis.DataCase
  import Mox

  alias Thevis.Scans
  alias Thevis.Scans.ScanResult
  alias Thevis.Scans.ScanRun

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "scan_runs" do
    @valid_attrs %{
      status: :pending,
      scan_type: :entity_probe
    }
    @update_attrs %{
      status: :running,
      scan_type: :recall
    }
    @invalid_attrs %{status: nil, scan_type: nil, project_id: nil}

    setup do
      project = insert(:product_project)
      {:ok, project: project}
    end

    test "list_scan_runs/1 returns all scan runs for a project", %{project: project} do
      scan_run = insert(:scan_run, project: project)
      _other_scan_run = insert(:scan_run)

      scan_runs = Scans.list_scan_runs(project)

      assert length(scan_runs) == 1
      assert hd(scan_runs).id == scan_run.id
    end

    test "get_scan_run!/1 returns the scan run with given id", %{project: project} do
      scan_run = insert(:scan_run, project: project)
      found_scan_run = Scans.get_scan_run!(scan_run.id)

      assert found_scan_run.id == scan_run.id
      assert found_scan_run.status == scan_run.status
      assert found_scan_run.scan_type == scan_run.scan_type
    end

    test "create_scan_run/2 with valid data creates a scan run", %{project: project} do
      assert {:ok, %ScanRun{} = scan_run} = Scans.create_scan_run(project, @valid_attrs)
      assert scan_run.status == :pending
      assert scan_run.scan_type == :entity_probe
      assert scan_run.project_id == project.id
    end

    test "create_scan_run/2 defaults status to pending", %{project: project} do
      attrs = Map.delete(@valid_attrs, :status)
      assert {:ok, %ScanRun{} = scan_run} = Scans.create_scan_run(project, attrs)
      assert scan_run.status == :pending
    end

    test "create_scan_run/2 with invalid data returns error changeset", %{project: project} do
      assert {:error, %Ecto.Changeset{}} = Scans.create_scan_run(project, @invalid_attrs)
    end

    test "update_scan_run/2 with valid data updates the scan run", %{project: project} do
      scan_run = insert(:scan_run, project: project)
      assert {:ok, %ScanRun{} = scan_run} = Scans.update_scan_run(scan_run, @update_attrs)
      assert scan_run.status == :running
      assert scan_run.scan_type == :recall
    end

    test "update_scan_run/2 with invalid data returns error changeset", %{project: project} do
      scan_run = insert(:scan_run, project: project)
      assert {:error, %Ecto.Changeset{}} = Scans.update_scan_run(scan_run, @invalid_attrs)

      # Compare only the relevant fields, not preloaded associations
      fetched_scan_run = Scans.get_scan_run!(scan_run.id)
      assert scan_run.id == fetched_scan_run.id
      assert scan_run.status == fetched_scan_run.status
      assert scan_run.scan_type == fetched_scan_run.scan_type
      assert scan_run.project_id == fetched_scan_run.project_id
    end

    test "delete_scan_run/1 deletes the scan run", %{project: project} do
      scan_run = insert(:scan_run, project: project)
      assert {:ok, %ScanRun{}} = Scans.delete_scan_run(scan_run)
      assert_raise Ecto.NoResultsError, fn -> Scans.get_scan_run!(scan_run.id) end
    end

    test "mark_scan_started/1 marks scan as running", %{project: project} do
      scan_run = insert(:scan_run, project: project, status: :pending)
      assert {:ok, %ScanRun{} = updated} = Scans.mark_scan_started(scan_run)
      assert updated.status == :running
      assert updated.started_at != nil
    end

    test "mark_scan_completed/1 marks scan as completed", %{project: project} do
      scan_run = insert(:scan_run, project: project, status: :running)
      assert {:ok, %ScanRun{} = updated} = Scans.mark_scan_completed(scan_run)
      assert updated.status == :completed
      assert updated.completed_at != nil
    end

    test "mark_scan_failed/1 marks scan as failed", %{project: project} do
      scan_run = insert(:scan_run, project: project, status: :running)
      assert {:ok, %ScanRun{} = updated} = Scans.mark_scan_failed(scan_run)
      assert updated.status == :failed
      assert updated.completed_at != nil
    end
  end

  describe "scan_results" do
    alias Thevis.Scans.ScanRun

    @valid_attrs %{
      result_type: "entity_probe",
      data: %{"key" => "value"},
      metrics: %{"score" => 0.85}
    }
    @invalid_attrs %{result_type: nil, scan_run_id: nil}

    setup do
      scan_run = insert(:scan_run)
      {:ok, scan_run: scan_run}
    end

    test "list_scan_results/1 returns all scan results for a scan run", %{scan_run: scan_run} do
      scan_result = insert(:scan_result, scan_run: scan_run)
      _other_scan_result = insert(:scan_result)

      scan_results = Scans.list_scan_results(scan_run)

      assert length(scan_results) == 1
      assert hd(scan_results).id == scan_result.id
    end

    test "create_scan_result/2 with valid data creates a scan result", %{scan_run: scan_run} do
      assert {:ok, %ScanResult{} = scan_result} = Scans.create_scan_result(scan_run, @valid_attrs)
      assert scan_result.result_type == "entity_probe"
      assert scan_result.data == %{"key" => "value"}
      assert scan_result.metrics == %{"score" => 0.85}
      assert scan_result.scan_run_id == scan_run.id
    end

    test "create_scan_result/2 with invalid data returns error changeset", %{scan_run: scan_run} do
      assert {:error, %Ecto.Changeset{}} = Scans.create_scan_result(scan_run, @invalid_attrs)
    end

    test "get_latest_results/1 returns results from most recent scan run", %{scan_run: scan_run} do
      project = scan_run.project

      # Create an older scan run with results (inserted first, so older timestamp)
      old_scan_run = insert(:scan_run, project: project)
      _old_result = insert(:scan_result, scan_run: old_scan_run, result_type: "old")

      # Wait a bit to ensure timestamp difference
      Process.sleep(10)

      # Create a newer scan run with results
      new_scan_run = insert(:scan_run, project: project)
      new_result = insert(:scan_result, scan_run: new_scan_run, result_type: "new")

      results = Scans.get_latest_results(project)

      assert length(results) == 1
      assert hd(results).id == new_result.id
      assert hd(results).result_type == "new"
    end

    test "get_latest_results/1 returns empty list when no scan runs exist" do
      project = insert(:product_project)
      assert Scans.get_latest_results(project) == []
    end
  end

  describe "recall scan execution" do
    setup do
      project = insert(:product_project)
      {:ok, project: project}
    end

    test "execute_scan/1 with recall type executes recall tests", %{project: project} do
      {:ok, scan_run} =
        Scans.create_scan_run(project, %{
          scan_type: :recall,
          status: :pending
        })

      # Mock AI adapter for recall tests
      Thevis.AI.MockAdapter
      |> expect(:chat_completion, 6, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "#{project.product.name} is a great product."
               }
             }
           ]
         }}
      end)

      assert {:ok, _results} = Scans.execute_scan(scan_run)

      # Verify scan is completed
      updated_scan_run = Scans.get_scan_run!(scan_run.id)
      assert updated_scan_run.status == :completed
      assert updated_scan_run.completed_at != nil

      # Verify recall results were stored
      recall_results = Thevis.Geo.list_recall_results(scan_run)
      assert recall_results != []
    end

    test "execute_scan/1 with recall type handles errors", %{project: project} do
      {:ok, scan_run} =
        Scans.create_scan_run(project, %{
          scan_type: :recall,
          status: :pending
        })

      # Mock AI adapter to return error (test_recall generates 6 prompts by default)
      Thevis.AI.MockAdapter
      |> expect(:chat_completion, 6, fn _messages, _opts ->
        {:error, :timeout}
      end)

      assert {:error, :all_tests_failed} = Scans.execute_scan(scan_run)

      # Verify scan is marked as failed
      updated_scan_run = Scans.get_scan_run!(scan_run.id)
      assert updated_scan_run.status == :failed
    end
  end
end

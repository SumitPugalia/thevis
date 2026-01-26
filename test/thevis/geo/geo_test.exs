defmodule Thevis.GeoTest do
  use Thevis.DataCase

  alias Thevis.Geo
  alias Thevis.Geo.EntitySnapshot

  describe "entity_snapshots" do
    alias Thevis.Scans.ScanRun

    @valid_attrs %{
      optimizable_type: :product,
      optimizable_id: Ecto.UUID.generate(),
      ai_description: "A test AI description",
      confidence_score: 0.85,
      source_llm: "gpt-4o-mini",
      prompt_template: "product_probe"
    }
    @invalid_attrs %{optimizable_type: nil, optimizable_id: nil, ai_description: nil}

    setup do
      scan_run = insert(:scan_run)
      {:ok, scan_run: scan_run}
    end

    test "list_entity_snapshots/1 returns all snapshots for a scan run", %{scan_run: scan_run} do
      snapshot = insert(:entity_snapshot, scan_run: scan_run)
      _other_snapshot = insert(:entity_snapshot)

      snapshots = Geo.list_entity_snapshots(scan_run)

      assert length(snapshots) == 1
      assert hd(snapshots).id == snapshot.id
    end

    test "get_entity_snapshot/1 returns the snapshot with given id", %{scan_run: scan_run} do
      snapshot = insert(:entity_snapshot, scan_run: scan_run)
      found_snapshot = Geo.get_entity_snapshot(snapshot.id)

      assert found_snapshot.id == snapshot.id
      assert found_snapshot.ai_description == snapshot.ai_description
    end

    test "create_entity_snapshot/2 with valid data creates a snapshot", %{scan_run: scan_run} do
      assert {:ok, %EntitySnapshot{} = snapshot} =
               Geo.create_entity_snapshot(scan_run, @valid_attrs)

      assert snapshot.optimizable_type == :product
      assert snapshot.ai_description == "A test AI description"
      assert snapshot.confidence_score == 0.85
      assert snapshot.scan_run_id == scan_run.id
    end

    test "create_entity_snapshot/2 with invalid data returns error changeset", %{
      scan_run: scan_run
    } do
      assert {:error, %Ecto.Changeset{}} = Geo.create_entity_snapshot(scan_run, @invalid_attrs)
    end

    test "get_latest_snapshot/2 returns the most recent snapshot for an entity" do
      product = insert(:product)
      scan_run1 = insert(:scan_run)
      scan_run2 = insert(:scan_run)

      # Create older snapshot
      _old_snapshot =
        insert(:entity_snapshot,
          scan_run: scan_run1,
          optimizable_type: :product,
          optimizable_id: product.id
        )

      # Wait a bit to ensure timestamp difference
      Process.sleep(10)

      # Create newer snapshot
      new_snapshot =
        insert(:entity_snapshot,
          scan_run: scan_run2,
          optimizable_type: :product,
          optimizable_id: product.id
        )

      latest = Geo.get_latest_snapshot(:product, product.id)

      assert latest.id == new_snapshot.id
    end
  end
end

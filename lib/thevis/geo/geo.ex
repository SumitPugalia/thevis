defmodule Thevis.Geo do
  @moduledoc """
  The Geo context for GEO engine operations and entity snapshot management.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Geo.EntitySnapshot
  alias Thevis.Scans.ScanRun

  ## Entity Snapshots

  @doc """
  Returns the list of entity snapshots for a scan run.

  ## Examples

      iex> list_entity_snapshots(scan_run)
      [%EntitySnapshot{}, ...]

  """
  def list_entity_snapshots(%ScanRun{} = scan_run) do
    EntitySnapshot
    |> where([e], e.scan_run_id == ^scan_run.id)
    |> order_by([e], desc: e.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single entity snapshot.

  Returns `nil` if the EntitySnapshot does not exist.

  ## Examples

      iex> get_entity_snapshot(id)
      %EntitySnapshot{}

      iex> get_entity_snapshot(456)
      nil

  """
  def get_entity_snapshot(id), do: Repo.get(EntitySnapshot, id)

  @doc """
  Creates an entity snapshot.

  ## Examples

      iex> create_entity_snapshot(scan_run, %{optimizable_type: :product, ...})
      {:ok, %EntitySnapshot{}}

      iex> create_entity_snapshot(scan_run, %{optimizable_type: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_entity_snapshot(%ScanRun{} = scan_run, attrs \\ %{}) do
    # Convert all keys to strings to avoid mixed key errors
    attrs_string_keys = for {k, v} <- attrs, into: %{}, do: {to_string(k), v}
    attrs_with_scan_run = Map.put(attrs_string_keys, "scan_run_id", scan_run.id)

    %EntitySnapshot{}
    |> EntitySnapshot.changeset(attrs_with_scan_run)
    |> Repo.insert()
  end

  @doc """
  Gets the latest entity snapshot for an optimizable entity.

  ## Examples

      iex> get_latest_snapshot(:product, product_id)
      %EntitySnapshot{}

      iex> get_latest_snapshot(:product, product_id)
      nil

  """
  def get_latest_snapshot(optimizable_type, optimizable_id) do
    EntitySnapshot
    |> where([e], e.optimizable_type == ^optimizable_type and e.optimizable_id == ^optimizable_id)
    |> order_by([e], desc: e.inserted_at)
    |> limit(1)
    |> Repo.one()
  end
end

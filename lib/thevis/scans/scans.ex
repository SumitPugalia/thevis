defmodule Thevis.Scans do
  @moduledoc """
  The Scans context for scan execution and result management.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Geo
  alias Thevis.Geo.EntityProbe
  alias Thevis.Projects
  alias Thevis.Projects.Project
  alias Thevis.Scans.ScanResult
  alias Thevis.Scans.ScanRun

  ## Scan Runs

  @doc """
  Returns the list of scan runs for a project.

  ## Examples

      iex> list_scan_runs(project)
      [%ScanRun{}, ...]

  """
  def list_scan_runs(%Project{} = project) do
    ScanRun
    |> where([s], s.project_id == ^project.id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single scan run.

  Returns `nil` if the ScanRun does not exist.

  ## Examples

      iex> get_scan_run(id)
      %ScanRun{}

      iex> get_scan_run(456)
      nil

  """
  def get_scan_run(id), do: Repo.get(ScanRun, id)

  @doc """
  Gets a single scan run with preloaded associations.

  Returns `nil` if the ScanRun does not exist.

  ## Examples

      iex> get_scan_run!(id)
      %ScanRun{}

      iex> get_scan_run!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scan_run!(id) do
    ScanRun
    |> Repo.get!(id)
    |> Repo.preload([:project, :scan_results])
  end

  @doc """
  Creates a scan run.

  ## Examples

      iex> create_scan_run(project, %{scan_type: :entity_probe})
      {:ok, %ScanRun{}}

      iex> create_scan_run(project, %{scan_type: :invalid})
      {:error, %Ecto.Changeset{}}

  """
  def create_scan_run(%Project{} = project, attrs \\ %{}) do
    # Convert all keys to strings to avoid mixed key errors
    attrs_string_keys = for {k, v} <- attrs, into: %{}, do: {to_string(k), v}
    attrs_with_project = Map.put(attrs_string_keys, "project_id", project.id)
    attrs_with_status = Map.put_new(attrs_with_project, "status", "pending")

    %ScanRun{}
    |> ScanRun.changeset(attrs_with_status)
    |> Repo.insert()
  end

  @doc """
  Updates a scan run.

  ## Examples

      iex> update_scan_run(scan_run, %{status: :completed})
      {:ok, %ScanRun{}}

      iex> update_scan_run(scan_run, %{status: :invalid})
      {:error, %Ecto.Changeset{}}

  """
  def update_scan_run(%ScanRun{} = scan_run, attrs) do
    scan_run
    |> ScanRun.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scan run.

  ## Examples

      iex> delete_scan_run(scan_run)
      {:ok, %ScanRun{}}

      iex> delete_scan_run(scan_run)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scan_run(%ScanRun{} = scan_run) do
    Repo.delete(scan_run)
  end

  @doc """
  Marks a scan run as started.

  ## Examples

      iex> mark_scan_started(scan_run)
      {:ok, %ScanRun{}}

  """
  def mark_scan_started(%ScanRun{} = scan_run) do
    now = DateTime.utc_now()

    scan_run
    |> ScanRun.changeset(%{status: :running, started_at: now})
    |> Repo.update()
  end

  @doc """
  Marks a scan run as completed.

  ## Examples

      iex> mark_scan_completed(scan_run)
      {:ok, %ScanRun{}}

  """
  def mark_scan_completed(%ScanRun{} = scan_run) do
    now = DateTime.utc_now()

    scan_run
    |> ScanRun.changeset(%{status: :completed, completed_at: now})
    |> Repo.update()
  end

  @doc """
  Marks a scan run as failed.

  ## Examples

      iex> mark_scan_failed(scan_run)
      {:ok, %ScanRun{}}

  """
  def mark_scan_failed(%ScanRun{} = scan_run) do
    now = DateTime.utc_now()

    scan_run
    |> ScanRun.changeset(%{status: :failed, completed_at: now})
    |> Repo.update()
  end

  ## Scan Results

  @doc """
  Returns the list of scan results for a scan run.

  ## Examples

      iex> list_scan_results(scan_run)
      [%ScanResult{}, ...]

  """
  def list_scan_results(%ScanRun{} = scan_run) do
    ScanResult
    |> where([s], s.scan_run_id == ^scan_run.id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single scan result.

  Returns `nil` if the ScanResult does not exist.

  ## Examples

      iex> get_scan_result(id)
      %ScanResult{}

      iex> get_scan_result(456)
      nil

  """
  def get_scan_result(id), do: Repo.get(ScanResult, id)

  @doc """
  Creates a scan result.

  ## Examples

      iex> create_scan_result(scan_run, %{result_type: "entity_probe", data: %{}})
      {:ok, %ScanResult{}}

      iex> create_scan_result(scan_run, %{result_type: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_scan_result(%ScanRun{} = scan_run, attrs \\ %{}) do
    # Convert all keys to strings to avoid mixed key errors
    attrs_string_keys = for {k, v} <- attrs, into: %{}, do: {to_string(k), v}
    attrs_with_scan_run = Map.put(attrs_string_keys, "scan_run_id", scan_run.id)

    %ScanResult{}
    |> ScanResult.changeset(attrs_with_scan_run)
    |> Repo.insert()
  end

  @doc """
  Gets the latest scan results for a project.

  ## Examples

      iex> get_latest_results(project)
      [%ScanResult{}, ...]

  """
  def get_latest_results(%Project{} = project) do
    # Get the most recent scan run for the project
    latest_scan_run =
      ScanRun
      |> where([s], s.project_id == ^project.id)
      |> order_by([s], desc: s.inserted_at)
      |> limit(1)
      |> Repo.one()

    if latest_scan_run do
      list_scan_results(latest_scan_run)
    else
      []
    end
  end

  @doc """
  Executes an entity probe scan.

  This function:
  1. Marks the scan run as started
  2. Gets the optimizable entity from the project
  3. Probes the entity using the Entity Probe Engine
  4. Stores the entity snapshot
  5. Marks the scan run as completed or failed

  ## Examples

      iex> execute_scan(scan_run)
      {:ok, %EntitySnapshot{}}

      iex> execute_scan(scan_run)
      {:error, reason}

  """
  def execute_scan(%ScanRun{scan_type: :entity_probe} = scan_run) do
    {:ok, scan_run} = mark_scan_started(scan_run)

    project =
      scan_run.project_id
      |> Projects.get_project!()
      |> Thevis.Repo.preload(:product)

    if is_nil(project.product) do
      mark_scan_failed(scan_run)
      {:error, :product_not_found}
    else
      probe_and_store_snapshot(scan_run, project.product)
    end
  end

  def execute_scan(%ScanRun{} = scan_run) do
    {:error, {:unsupported_scan_type, scan_run.scan_type}}
  end

  defp probe_and_store_snapshot(scan_run, product) do
    case EntityProbe.probe_entity(product) do
      {:ok, snapshot_data} ->
        store_snapshot(scan_run, snapshot_data)

      {:error, reason} ->
        mark_scan_failed(scan_run)
        {:error, reason}
    end
  end

  defp store_snapshot(scan_run, snapshot_data) do
    case Geo.create_entity_snapshot(scan_run, snapshot_data) do
      {:ok, snapshot} ->
        mark_scan_completed(scan_run)
        {:ok, snapshot}

      {:error, changeset} ->
        mark_scan_failed(scan_run)
        {:error, changeset}
    end
  end
end

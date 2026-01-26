defmodule Thevis.Scans.ScanRun do
  @moduledoc """
  ScanRun schema representing a scan execution.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "scan_runs" do
    field :status, Ecto.Enum, values: [:pending, :running, :completed, :failed]
    field :scan_type, Ecto.Enum, values: [:entity_probe, :recall, :authority, :consistency, :full]
    field :started_at, :utc_datetime_usec
    field :completed_at, :utc_datetime_usec

    belongs_to :project, Project

    has_many :scan_results, Thevis.Scans.ScanResult

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          status: :pending | :running | :completed | :failed,
          scan_type: :entity_probe | :recall | :authority | :consistency | :full,
          started_at: DateTime.t() | nil,
          completed_at: DateTime.t() | nil,
          project_id: binary(),
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          scan_results: Ecto.Association.NotLoaded.t() | [Thevis.Scans.ScanResult.t()],
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(scan_run, attrs) do
    scan_run
    |> cast(attrs, [:status, :scan_type, :started_at, :completed_at, :project_id])
    |> validate_required([:status, :scan_type, :project_id])
    |> validate_inclusion(:status, [:pending, :running, :completed, :failed])
    |> validate_inclusion(:scan_type, [:entity_probe, :recall, :authority, :consistency, :full])
    |> foreign_key_constraint(:project_id)
  end
end

defmodule Thevis.Scans.ScanResult do
  @moduledoc """
  ScanResult schema representing scan result data.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Scans.ScanRun

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "scan_results" do
    field :result_type, :string
    field :data, :map
    field :metrics, :map

    belongs_to :scan_run, ScanRun

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(scan_result, attrs) do
    scan_result
    |> cast(attrs, [:result_type, :data, :metrics, :scan_run_id])
    |> validate_required([:result_type, :scan_run_id])
    |> validate_length(:result_type, min: 1, max: 255)
    |> foreign_key_constraint(:scan_run_id)
  end
end

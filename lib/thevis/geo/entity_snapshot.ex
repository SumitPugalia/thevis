defmodule Thevis.Geo.EntitySnapshot do
  @moduledoc """
  EntitySnapshot schema representing AI's recognition of a product or company.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Scans.ScanRun

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "entity_snapshots" do
    field :optimizable_type, Ecto.Enum, values: [:product, :service]
    field :optimizable_id, :binary_id
    field :ai_description, :string
    field :confidence_score, :float
    field :source_llm, :string
    field :prompt_template, :string

    belongs_to :scan_run, ScanRun

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(entity_snapshot, attrs) do
    entity_snapshot
    |> cast(attrs, [
      :optimizable_type,
      :optimizable_id,
      :ai_description,
      :confidence_score,
      :source_llm,
      :prompt_template,
      :scan_run_id
    ])
    |> validate_required([
      :optimizable_type,
      :optimizable_id,
      :ai_description,
      :scan_run_id
    ])
    |> validate_inclusion(:optimizable_type, [:product, :service])
    |> validate_number(:confidence_score,
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    )
    |> foreign_key_constraint(:scan_run_id)
  end
end

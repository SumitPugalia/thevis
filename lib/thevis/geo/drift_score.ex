defmodule Thevis.Geo.DriftScore do
  @moduledoc """
  DriftScore schema representing messaging consistency/drift for products or companies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "drift_scores" do
    field :optimizable_type, Ecto.Enum, values: [:product, :service]
    field :optimizable_id, :binary_id
    field :drift_score, :float
    field :source_type, :string
    field :source_description, :string
    field :reference_description, :string
    field :similarity_score, :float
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          optimizable_type: :product | :service,
          optimizable_id: binary(),
          drift_score: float(),
          source_type: String.t(),
          source_description: String.t() | nil,
          reference_description: String.t() | nil,
          similarity_score: float() | nil,
          metadata: map(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(drift_score, attrs) do
    drift_score
    |> cast(attrs, [
      :optimizable_type,
      :optimizable_id,
      :drift_score,
      :source_type,
      :source_description,
      :reference_description,
      :similarity_score,
      :metadata
    ])
    |> validate_required([
      :optimizable_type,
      :optimizable_id,
      :drift_score,
      :source_type
    ])
    |> validate_inclusion(:optimizable_type, [:product, :service])
    |> validate_number(:drift_score,
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    )
    |> validate_number(:similarity_score,
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    )
  end
end

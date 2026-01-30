defmodule Thevis.Geo.AuthorityScore do
  @moduledoc """
  AuthorityScore schema representing authority signals for products or companies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "authority_scores" do
    field :optimizable_type, Ecto.Enum, values: [:product, :service]
    field :optimizable_id, :binary_id
    field :authority_score, :float
    field :source_type, :string
    field :source_url, :string
    field :source_title, :string
    field :source_content, :string
    field :crawled_at, :utc_datetime_usec
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          optimizable_type: :product | :service,
          optimizable_id: binary(),
          authority_score: float(),
          source_type: String.t(),
          source_url: String.t() | nil,
          source_title: String.t() | nil,
          source_content: String.t() | nil,
          crawled_at: DateTime.t() | nil,
          metadata: map(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(authority_score, attrs) do
    authority_score
    |> cast(attrs, [
      :optimizable_type,
      :optimizable_id,
      :authority_score,
      :source_type,
      :source_url,
      :source_title,
      :source_content,
      :crawled_at,
      :metadata
    ])
    |> validate_required([
      :optimizable_type,
      :optimizable_id,
      :authority_score,
      :source_type
    ])
    |> validate_inclusion(:optimizable_type, [:product, :service])
    |> validate_number(:authority_score,
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    )
  end
end

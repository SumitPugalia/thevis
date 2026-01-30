defmodule Thevis.Geo.Embedding do
  @moduledoc """
  Embedding schema for storing vector embeddings of text content.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "embeddings" do
    field :optimizable_type, Ecto.Enum, values: [:product, :service]
    field :optimizable_id, :binary_id
    field :text_content, :string
    field :source_type, :string
    field :source_url, :string
    field :embedding, Pgvector.Ecto.Vector

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          optimizable_type: :product | :service,
          optimizable_id: binary(),
          text_content: String.t(),
          source_type: String.t(),
          source_url: String.t() | nil,
          embedding: Pgvector.Ecto.Vector.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(embedding, attrs) do
    embedding
    |> cast(attrs, [
      :optimizable_type,
      :optimizable_id,
      :text_content,
      :source_type,
      :source_url,
      :embedding
    ])
    |> validate_required([
      :optimizable_type,
      :optimizable_id,
      :text_content,
      :source_type,
      :embedding
    ])
    |> validate_inclusion(:optimizable_type, [:product, :service])
    |> maybe_convert_embedding()
  end

  defp maybe_convert_embedding(%Ecto.Changeset{changes: %{embedding: embedding}} = changeset)
       when is_list(embedding) do
    # Convert list to Pgvector.Ecto.Vector if needed
    # pgvector should handle this automatically, but we ensure it's a list
    changeset
  end

  defp maybe_convert_embedding(changeset), do: changeset
end

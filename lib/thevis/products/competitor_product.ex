defmodule Thevis.Products.CompetitorProduct do
  @moduledoc """
  CompetitorProduct schema for tracking competitor products.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "competitor_products" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :brand_name, :string

    belongs_to :product, Thevis.Products.Product

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t() | nil,
          category: String.t() | nil,
          brand_name: String.t() | nil,
          product_id: binary(),
          product: Thevis.Products.Product.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(competitor_product, attrs) do
    competitor_product
    |> cast(attrs, [:name, :description, :category, :brand_name, :product_id])
    |> validate_required([:name, :product_id])
    |> validate_length(:name, min: 1, max: 255)
    |> foreign_key_constraint(:product_id)
  end
end

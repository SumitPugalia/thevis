defmodule Thevis.Products.Product do
  @moduledoc """
  Product schema representing products that can be optimized.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "products" do
    field :name, :string
    field :description, :string
    field :category, :string

    field :product_type, Ecto.Enum,
      values: [:cosmetic, :edible, :sweet, :d2c, :fashion, :wellness, :other]

    field :launch_date, :date
    field :launch_window_start, :date
    field :launch_window_end, :date

    belongs_to :company, Thevis.Accounts.Company
    has_many :competitor_products, Thevis.Products.CompetitorProduct

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t() | nil,
          category: String.t() | nil,
          product_type: :cosmetic | :edible | :sweet | :d2c | :fashion | :wellness | :other,
          launch_date: Date.t() | nil,
          launch_window_start: Date.t() | nil,
          launch_window_end: Date.t() | nil,
          company_id: binary(),
          company: Ecto.Association.NotLoaded.t() | Thevis.Accounts.Company.t(),
          competitor_products:
            Ecto.Association.NotLoaded.t() | [Thevis.Products.CompetitorProduct.t()],
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc """
  Computed field: checks if product is currently in launch window.
  """
  def launch_window_active?(%__MODULE__{
        launch_window_start: start_date,
        launch_window_end: end_date
      })
      when not is_nil(start_date) and not is_nil(end_date) do
    today = Date.utc_today()
    Date.compare(today, start_date) != :lt && Date.compare(today, end_date) != :gt
  end

  def launch_window_active?(_), do: false

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :category,
      :product_type,
      :launch_date,
      :launch_window_start,
      :launch_window_end,
      :company_id
    ])
    |> validate_required([:name, :product_type, :company_id])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_launch_window_dates()
    |> foreign_key_constraint(:company_id)
  end

  defp validate_launch_window_dates(changeset) do
    start_date = get_change(changeset, :launch_window_start)
    end_date = get_change(changeset, :launch_window_end)

    cond do
      is_nil(start_date) && is_nil(end_date) ->
        changeset

      is_nil(start_date) && not is_nil(end_date) ->
        add_error(changeset, :launch_window_start, "must be set when launch_window_end is set")

      not is_nil(start_date) && is_nil(end_date) ->
        add_error(changeset, :launch_window_end, "must be set when launch_window_start is set")

      Date.compare(start_date, end_date) == :gt ->
        add_error(changeset, :launch_window_start, "must be before or equal to launch_window_end")

      true ->
        changeset
    end
  end
end

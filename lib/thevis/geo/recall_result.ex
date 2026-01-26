defmodule Thevis.Geo.RecallResult do
  @moduledoc """
  RecallResult schema representing the result of a recall test.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Products.Product
  alias Thevis.Scans.ScanRun

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "recall_results" do
    field :prompt_category, :string
    field :prompt_text, :string
    field :mentioned, :boolean, default: false
    field :mention_rank, :integer
    field :response_text, :string
    field :raw_response, :map

    belongs_to :scan_run, ScanRun, type: :binary_id
    belongs_to :product, Product, type: :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(recall_result, attrs) do
    recall_result
    |> cast(attrs, [
      :prompt_category,
      :prompt_text,
      :mentioned,
      :mention_rank,
      :response_text,
      :raw_response,
      :scan_run_id,
      :product_id
    ])
    |> validate_required([
      :prompt_category,
      :prompt_text,
      :mentioned,
      :scan_run_id,
      :product_id
    ])
    |> validate_inclusion(:prompt_category, [
      "product_search",
      "category_search",
      "use_case",
      "comparison",
      "recommendation",
      "general"
    ])
    |> foreign_key_constraint(:scan_run_id)
    |> foreign_key_constraint(:product_id)
  end
end

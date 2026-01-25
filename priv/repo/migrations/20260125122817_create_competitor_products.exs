defmodule Thevis.Repo.Migrations.CreateCompetitorProducts do
  use Ecto.Migration

  def change do
    create table(:competitor_products, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all),
        null: false

      add :name, :string, null: false
      add :description, :text
      add :category, :string
      add :brand_name, :string

      timestamps(type: :utc_datetime_usec)
    end

    create index(:competitor_products, [:product_id])
  end
end

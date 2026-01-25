defmodule Thevis.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false

      add :name, :string, null: false
      add :description, :text
      add :category, :string
      add :product_type, :string, null: false
      add :launch_date, :date
      add :launch_window_start, :date
      add :launch_window_end, :date

      timestamps(type: :utc_datetime_usec)
    end

    create index(:products, [:company_id])
    create index(:products, [:product_type])
    create index(:products, [:launch_date])
    create index(:products, [:launch_window_start, :launch_window_end])
  end
end

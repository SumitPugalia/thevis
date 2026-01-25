defmodule Thevis.Repo.Migrations.CreateServices do
  use Ecto.Migration

  def change do
    create table(:services, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false

      add :name, :string, null: false
      add :description, :text
      add :category, :string
      add :service_type, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:services, [:company_id])
    create index(:services, [:service_type])
  end
end

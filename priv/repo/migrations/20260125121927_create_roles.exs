defmodule Thevis.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false

      add :role_type, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:roles, [:user_id, :company_id])
    create index(:roles, [:user_id])
    create index(:roles, [:company_id])
    create index(:roles, [:role_type])
  end
end

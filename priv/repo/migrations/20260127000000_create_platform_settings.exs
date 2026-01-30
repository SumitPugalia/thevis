defmodule Thevis.Repo.Migrations.CreatePlatformSettings do
  use Ecto.Migration

  def change do
    create table(:platform_settings, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :platform_type, :string, null: false
      add :settings, :map, default: %{}
      add :is_active, :boolean, default: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(:platform_settings, [:project_id])
    create index(:platform_settings, [:platform_type])
    create unique_index(:platform_settings, [:project_id, :platform_type])
  end
end

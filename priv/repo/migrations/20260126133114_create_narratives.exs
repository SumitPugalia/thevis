defmodule Thevis.Repo.Migrations.CreateNarratives do
  use Ecto.Migration

  def change do
    create table(:narratives, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :content, :text, null: false
      add :rules, :map, default: %{}
      add :version, :integer, default: 1, null: false
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:narratives, [:project_id])
    create index(:narratives, [:is_active])
    create index(:narratives, [:version])
  end
end

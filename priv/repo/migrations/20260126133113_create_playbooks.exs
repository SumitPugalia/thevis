defmodule Thevis.Repo.Migrations.CreatePlaybooks do
  use Ecto.Migration

  def change do
    create table(:playbooks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :category, :string, null: false
      add :steps, :map, default: %{}
      add :is_template, :boolean, default: false, null: false
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:playbooks, [:project_id])
    create index(:playbooks, [:category])
    create index(:playbooks, [:is_template])
  end
end

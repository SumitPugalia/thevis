defmodule Thevis.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :title, :string, null: false
      add :description, :text
      add :status, :string, default: "pending", null: false
      add :priority, :string, default: "medium", null: false
      add :assigned_to_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :due_date, :date
      add :completed_at, :utc_datetime_usec
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create index(:tasks, [:project_id])
    create index(:tasks, [:status])
    create index(:tasks, [:priority])
    create index(:tasks, [:assigned_to_id])
    create index(:tasks, [:due_date])
  end
end

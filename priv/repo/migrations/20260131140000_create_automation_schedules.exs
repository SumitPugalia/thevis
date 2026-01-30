defmodule Thevis.Repo.Migrations.CreateAutomationSchedules do
  use Ecto.Migration

  def change do
    create table(:automation_schedules, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all)

      add :task_type, :string, null: false
      add :frequency, :string, null: false
      add :enabled, :boolean, default: true, null: false
      add :next_run_at, :utc_datetime_usec
      add :last_run_at, :utc_datetime_usec
      add :options, :map, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create index(:automation_schedules, [:project_id])
    create index(:automation_schedules, [:task_type])
    create index(:automation_schedules, [:enabled])
    create index(:automation_schedules, [:next_run_at])
  end
end

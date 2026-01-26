defmodule Thevis.Repo.Migrations.CreateScanRuns do
  use Ecto.Migration

  def change do
    create table(:scan_runs, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :status, :string, null: false
      add :scan_type, :string, null: false
      add :started_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:scan_runs, [:project_id])
    create index(:scan_runs, [:status])
    create index(:scan_runs, [:scan_type])
    create index(:scan_runs, [:started_at])
  end
end

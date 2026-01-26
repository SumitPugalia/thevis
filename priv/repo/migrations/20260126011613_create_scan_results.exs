defmodule Thevis.Repo.Migrations.CreateScanResults do
  use Ecto.Migration

  def change do
    create table(:scan_results, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :scan_run_id, references(:scan_runs, type: :binary_id, on_delete: :delete_all),
        null: false

      add :result_type, :string, null: false
      add :data, :map
      add :metrics, :map

      timestamps(type: :utc_datetime_usec)
    end

    create index(:scan_results, [:scan_run_id])
    create index(:scan_results, [:result_type])
  end
end

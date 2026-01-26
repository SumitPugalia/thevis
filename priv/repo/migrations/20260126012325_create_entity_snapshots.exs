defmodule Thevis.Repo.Migrations.CreateEntitySnapshots do
  use Ecto.Migration

  def change do
    create table(:entity_snapshots, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :scan_run_id, references(:scan_runs, type: :binary_id, on_delete: :delete_all),
        null: false

      add :optimizable_type, :string, null: false
      add :optimizable_id, :binary_id, null: false
      add :ai_description, :text, null: false
      add :confidence_score, :float
      add :source_llm, :string
      add :prompt_template, :string

      timestamps(type: :utc_datetime_usec)
    end

    create index(:entity_snapshots, [:scan_run_id])
    create index(:entity_snapshots, [:optimizable_type, :optimizable_id])
  end
end

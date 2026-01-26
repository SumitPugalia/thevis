defmodule Thevis.Repo.Migrations.CreateRecallResults do
  use Ecto.Migration

  def change do
    create table(:recall_results, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :prompt_category, :string, null: false
      add :prompt_text, :text, null: false
      add :mentioned, :boolean, default: false, null: false
      add :mention_rank, :integer
      add :response_text, :text
      add :raw_response, :map

      add :scan_run_id, references(:scan_runs, type: :binary_id, on_delete: :delete_all),
        null: false

      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:recall_results, [:scan_run_id])
    create index(:recall_results, [:product_id])
    create index(:recall_results, [:prompt_category])
  end
end

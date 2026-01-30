defmodule Thevis.Repo.Migrations.CreateDriftScores do
  use Ecto.Migration

  def change do
    create table(:drift_scores, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :optimizable_type, :string, null: false
      add :optimizable_id, :binary_id, null: false
      add :drift_score, :float, null: false
      add :source_type, :string, null: false
      add :source_description, :text
      add :reference_description, :text
      add :similarity_score, :float
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create index(:drift_scores, [:optimizable_type, :optimizable_id])
    create index(:drift_scores, [:source_type])
    create index(:drift_scores, [:drift_score])
  end
end

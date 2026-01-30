defmodule Thevis.Repo.Migrations.CreateAuthorityScores do
  use Ecto.Migration

  def change do
    create table(:authority_scores, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :optimizable_type, :string, null: false
      add :optimizable_id, :binary_id, null: false
      add :authority_score, :float, null: false
      add :source_type, :string, null: false
      add :source_url, :string
      add :source_title, :string
      add :source_content, :text
      add :crawled_at, :utc_datetime_usec
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create index(:authority_scores, [:optimizable_type, :optimizable_id])
    create index(:authority_scores, [:source_type])
    create index(:authority_scores, [:authority_score])
  end
end

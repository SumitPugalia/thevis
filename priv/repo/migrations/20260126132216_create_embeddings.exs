defmodule Thevis.Repo.Migrations.CreateEmbeddings do
  use Ecto.Migration

  def change do
    create table(:embeddings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :optimizable_type, :string, null: false
      add :optimizable_id, :binary_id, null: false
      add :text_content, :text, null: false
      add :source_type, :string, null: false
      add :source_url, :string
      add :embedding, :vector, size: 1536, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:embeddings, [:optimizable_type, :optimizable_id])
    create index(:embeddings, [:source_type])

    execute(
      "CREATE INDEX embeddings_embedding_idx ON embeddings USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100)"
    )
  end
end

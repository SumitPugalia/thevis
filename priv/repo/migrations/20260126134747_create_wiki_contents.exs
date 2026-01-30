defmodule Thevis.Repo.Migrations.CreateWikiContents do
  use Ecto.Migration

  def change do
    create table(:wiki_contents, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :wiki_page_id, references(:wiki_pages, type: :binary_id, on_delete: :delete_all),
        null: false

      add :content, :text, null: false
      add :version, :integer, default: 1, null: false
      add :is_published, :boolean, default: false, null: false
      add :published_at, :utc_datetime_usec
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create index(:wiki_contents, [:wiki_page_id])
    create index(:wiki_contents, [:version])
    create index(:wiki_contents, [:is_published])
    create unique_index(:wiki_contents, [:wiki_page_id, :version])
  end
end

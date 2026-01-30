defmodule Thevis.Repo.Migrations.CreateWikiPages do
  use Ecto.Migration

  def change do
    create table(:wiki_pages, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :platform_id, references(:wiki_platforms, type: :binary_id, on_delete: :nilify_all)
      add :title, :string, null: false
      add :url, :string
      add :external_id, :string
      add :status, :string, default: "draft", null: false
      add :page_type, :string, default: "product", null: false
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create index(:wiki_pages, [:project_id])
    create index(:wiki_pages, [:platform_id])
    create index(:wiki_pages, [:status])
    create index(:wiki_pages, [:page_type])

    create unique_index(:wiki_pages, [:platform_id, :external_id],
             where: "external_id IS NOT NULL"
           )
  end
end

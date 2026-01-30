defmodule Thevis.Repo.Migrations.CreateWikiPlatforms do
  use Ecto.Migration

  def change do
    create table(:wiki_platforms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :platform_type, :string, null: false
      add :api_endpoint, :string
      add :api_key, :text
      add :config, :map, default: %{}
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:wiki_platforms, [:name])
    create index(:wiki_platforms, [:platform_type])
    create index(:wiki_platforms, [:is_active])
  end
end

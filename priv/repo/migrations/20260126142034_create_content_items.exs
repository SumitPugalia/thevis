defmodule Thevis.Repo.Migrations.CreateContentItems do
  use Ecto.Migration

  def change do
    create table(:content_items, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :campaign_id, references(:campaigns, type: :binary_id, on_delete: :delete_all),
        null: false

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :content_type, :string, null: false
      add :title, :string, null: false
      add :content, :text, null: false
      add :platform, :string, null: false
      add :status, :string, default: "draft", null: false
      add :published_url, :string
      add :ai_optimization_score, :float
      add :performance_metrics, :map, default: %{}
      add :scheduled_at, :utc_datetime_usec
      add :published_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:content_items, [:campaign_id])
    create index(:content_items, [:project_id])
    create index(:content_items, [:content_type])
    create index(:content_items, [:platform])
    create index(:content_items, [:status])
    create index(:content_items, [:scheduled_at])
  end
end

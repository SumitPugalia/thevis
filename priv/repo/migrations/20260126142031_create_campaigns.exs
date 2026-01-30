defmodule Thevis.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :playbook_id, references(:playbooks, type: :binary_id, on_delete: :nilify_all)
      add :name, :string, null: false
      add :description, :text
      add :status, :string, default: "draft", null: false
      add :campaign_type, :string, null: false
      add :intensity, :string, default: "standard", null: false
      add :launch_window_mode, :boolean, default: false, null: false
      add :goals, :map, default: %{}
      add :settings, :map, default: %{}
      add :started_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:campaigns, [:project_id])
    create index(:campaigns, [:playbook_id])
    create index(:campaigns, [:status])
    create index(:campaigns, [:campaign_type])
  end
end

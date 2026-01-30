defmodule Thevis.Repo.Migrations.CreateAutomationResults do
  use Ecto.Migration

  def change do
    create table(:automation_results, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :campaign_id, references(:campaigns, type: :binary_id, on_delete: :delete_all),
        null: false

      add :action_type, :string, null: false
      add :action_details, :map, default: %{}
      add :status, :string, default: "pending", null: false
      add :approved_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :approved_at, :utc_datetime_usec
      add :executed_at, :utc_datetime_usec
      add :performance_metrics, :map, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create index(:automation_results, [:campaign_id])
    create index(:automation_results, [:action_type])
    create index(:automation_results, [:status])
    create index(:automation_results, [:approved_by_id])
  end
end

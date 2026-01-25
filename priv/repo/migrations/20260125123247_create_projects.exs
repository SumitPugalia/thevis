defmodule Thevis.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :status, :string, null: false
      add :scan_frequency, :string, null: false
      add :project_type, :string, null: false
      add :urgency_level, :string, null: false
      add :is_category_project, :boolean, default: false, null: false
      add :optimizable_type, :string, null: false
      add :optimizable_id, :binary_id, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:projects, [:optimizable_type, :optimizable_id])
    create index(:projects, [:status])
    create index(:projects, [:project_type])
    create index(:projects, [:scan_frequency])
  end
end

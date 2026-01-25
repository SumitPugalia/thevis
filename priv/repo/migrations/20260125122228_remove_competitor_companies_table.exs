defmodule Thevis.Repo.Migrations.RemoveCompetitorCompaniesTable do
  use Ecto.Migration

  def up do
    drop_if_exists table(:competitor_companies)
  end

  def down do
    create table(:competitor_companies, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false

      add :competitor_name, :string, null: false
      add :competitor_domain, :string, null: false
      add :competitor_industry, :string
      add :notes, :text

      timestamps(type: :utc_datetime_usec)
    end

    create index(:competitor_companies, [:company_id])
    create unique_index(:competitor_companies, [:company_id, :competitor_domain])
  end
end

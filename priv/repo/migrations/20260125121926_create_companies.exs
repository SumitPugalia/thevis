defmodule Thevis.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :domain, :string, null: false
      add :industry, :string, null: false
      add :description, :text
      add :website_url, :string
      add :company_type, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:companies, [:domain])
    create index(:companies, [:company_type])
    create index(:companies, [:industry])
  end
end

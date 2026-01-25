defmodule Thevis.Repo.Migrations.AddCompetitorsToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :competitors, :jsonb, default: "[]"
    end

    create index(:companies, [:competitors], using: :gin)
  end
end

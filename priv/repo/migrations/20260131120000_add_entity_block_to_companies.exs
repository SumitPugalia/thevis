defmodule Thevis.Repo.Migrations.AddEntityBlockToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :category, :string
      add :one_line_definition, :string
      add :problem_solved, :string
      add :key_concepts, :string
    end
  end
end

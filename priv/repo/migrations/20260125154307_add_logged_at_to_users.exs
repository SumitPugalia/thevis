defmodule Thevis.Repo.Migrations.AddLoggedAtToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :logged_at, :utc_datetime_usec
    end

    create index(:users, [:logged_at])
  end
end

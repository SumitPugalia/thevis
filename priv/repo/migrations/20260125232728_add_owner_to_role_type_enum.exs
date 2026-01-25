defmodule Thevis.Repo.Migrations.AddOwnerToRoleTypeEnum do
  use Ecto.Migration

  def up do
    # Since role_type is stored as :string in the database (not a PostgreSQL enum),
    # we don't need to alter the enum type. The Ecto.Enum in the schema handles validation.
    # However, we should add a check constraint to ensure only valid values are stored.
    execute """
    ALTER TABLE roles
    ADD CONSTRAINT check_role_type
    CHECK (role_type IN ('consultant', 'client', 'owner'))
    """
  end

  def down do
    execute "ALTER TABLE roles DROP CONSTRAINT IF EXISTS check_role_type"

    execute """
    ALTER TABLE roles
    ADD CONSTRAINT check_role_type
    CHECK (role_type IN ('consultant', 'client'))
    """
  end
end

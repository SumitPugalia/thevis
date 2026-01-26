defmodule Thevis.Repo.Migrations.ReplaceOptimizableWithProductId do
  use Ecto.Migration

  def up do
    # Add product_id column (nullable initially for data migration)
    alter table(:projects) do
      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all), null: true
    end

    # Migrate existing data: copy optimizable_id to product_id where optimizable_type is 'product'
    execute("""
      UPDATE projects
      SET product_id = optimizable_id
      WHERE optimizable_type = 'product'
    """)

    # Remove old polymorphic columns
    alter table(:projects) do
      remove :optimizable_type
      remove :optimizable_id
    end

    # Make product_id required now that data is migrated
    alter table(:projects) do
      modify :product_id, :binary_id, null: false
    end

    # Drop old index if it exists and create new one
    drop_if_exists index(:projects, [:optimizable_type, :optimizable_id])
    create index(:projects, [:product_id])
  end

  def down do
    # Add back polymorphic columns
    alter table(:projects) do
      add :optimizable_type, :string, null: true
      add :optimizable_id, :binary_id, null: true
    end

    # Migrate data back
    execute("""
      UPDATE projects
      SET optimizable_type = 'product', optimizable_id = product_id
      WHERE product_id IS NOT NULL
    """)

    # Make required
    alter table(:projects) do
      modify :optimizable_type, :string, null: false
      modify :optimizable_id, :binary_id, null: false
    end

    # Drop product_id and its index
    drop index(:projects, [:product_id])

    alter table(:projects) do
      remove :product_id
    end

    # Recreate old index
    create index(:projects, [:optimizable_type, :optimizable_id])
  end
end

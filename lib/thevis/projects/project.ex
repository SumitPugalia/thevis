defmodule Thevis.Projects.Project do
  @moduledoc """
  Project schema with polymorphic associations.
  Projects can optimize products or services (companies).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects" do
    field :name, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:active, :paused, :archived]
    field :scan_frequency, Ecto.Enum, values: [:daily, :weekly, :monthly]
    field :project_type, Ecto.Enum, values: [:product_launch, :ongoing_monitoring, :audit_only]
    field :urgency_level, Ecto.Enum, values: [:standard, :high, :critical]
    field :is_category_project, :boolean, default: false
    field :optimizable_type, Ecto.Enum, values: [:product, :service]
    field :optimizable_id, :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :name,
      :description,
      :status,
      :scan_frequency,
      :project_type,
      :urgency_level,
      :is_category_project,
      :optimizable_type,
      :optimizable_id
    ])
    |> validate_required([
      :name,
      :status,
      :scan_frequency,
      :project_type,
      :urgency_level,
      :optimizable_type,
      :optimizable_id
    ])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_inclusion(:status, [:active, :paused, :archived])
    |> validate_inclusion(:project_type, [:product_launch, :ongoing_monitoring, :audit_only])
    |> validate_inclusion(:urgency_level, [:standard, :high, :critical])
  end
end

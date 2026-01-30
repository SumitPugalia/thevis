defmodule Thevis.Strategy.Playbook do
  @moduledoc """
  Playbook schema representing optimization strategies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "playbooks" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :steps, :map, default: %{}
    field :is_template, :boolean, default: false

    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t() | nil,
          category: String.t(),
          steps: map(),
          is_template: boolean(),
          project_id: binary() | nil,
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(playbook, attrs) do
    playbook
    |> cast(attrs, [:name, :description, :category, :steps, :is_template, :project_id])
    |> validate_required([:name, :category])
    |> validate_length(:name, min: 1, max: 255)
    |> foreign_key_constraint(:project_id)
  end
end

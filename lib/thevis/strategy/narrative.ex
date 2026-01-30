defmodule Thevis.Strategy.Narrative do
  @moduledoc """
  Narrative schema representing company narratives for optimization.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "narratives" do
    field :content, :string
    field :rules, :map, default: %{}
    field :version, :integer, default: 1
    field :is_active, :boolean, default: true

    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          content: String.t(),
          rules: map(),
          version: integer(),
          is_active: boolean(),
          project_id: binary(),
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(narrative, attrs) do
    narrative
    |> cast(attrs, [:content, :rules, :version, :is_active, :project_id])
    |> validate_required([:content, :project_id])
    |> validate_length(:content, min: 10)
    |> foreign_key_constraint(:project_id)
  end
end

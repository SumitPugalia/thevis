defmodule Thevis.Strategy.Task do
  @moduledoc """
  Task schema representing consultant tasks for project execution.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Accounts.User
  alias Thevis.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:pending, :in_progress, :completed, :blocked]
    field :priority, Ecto.Enum, values: [:low, :medium, :high, :critical]
    field :due_date, :date
    field :completed_at, :utc_datetime_usec
    field :metadata, :map, default: %{}

    belongs_to :project, Project
    belongs_to :assigned_to, User

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          title: String.t(),
          description: String.t() | nil,
          status: :pending | :in_progress | :completed | :blocked,
          priority: :low | :medium | :high | :critical,
          due_date: Date.t() | nil,
          completed_at: DateTime.t() | nil,
          metadata: map(),
          project_id: binary(),
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          assigned_to_id: binary() | nil,
          assigned_to: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :title,
      :description,
      :status,
      :priority,
      :due_date,
      :completed_at,
      :metadata,
      :project_id,
      :assigned_to_id
    ])
    |> validate_required([:title, :status, :priority, :project_id])
    |> validate_length(:title, min: 1, max: 255)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:assigned_to_id)
  end
end

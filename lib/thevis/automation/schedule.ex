defmodule Thevis.Automation.Schedule do
  @moduledoc """
  Schema for automation schedules (baseline scan, recurring scan, monitoring prompts).
  Admins can view, enable/disable, update frequency, run now, or delete.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @task_types [:baseline_scan, :recurring_scan, :monitoring_prompts]
  @frequencies [:once, :daily, :weekly, :monthly]

  schema "automation_schedules" do
    field :task_type, Ecto.Enum, values: @task_types
    field :frequency, Ecto.Enum, values: @frequencies
    field :enabled, :boolean, default: true
    field :next_run_at, :utc_datetime_usec
    field :last_run_at, :utc_datetime_usec
    field :options, :map, default: %{}

    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          project_id: binary() | nil,
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          task_type: :baseline_scan | :recurring_scan | :monitoring_prompts,
          frequency: :once | :daily | :weekly | :monthly,
          enabled: boolean(),
          next_run_at: DateTime.t() | nil,
          last_run_at: DateTime.t() | nil,
          options: map(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [
      :project_id,
      :task_type,
      :frequency,
      :enabled,
      :next_run_at,
      :last_run_at,
      :options
    ])
    |> validate_required([:task_type, :frequency])
    |> validate_inclusion(:task_type, @task_types)
    |> validate_inclusion(:frequency, @frequencies)
    |> foreign_key_constraint(:project_id)
  end
end

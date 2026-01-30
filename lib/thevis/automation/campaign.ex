defmodule Thevis.Automation.Campaign do
  @moduledoc """
  Campaign schema representing automation campaigns.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Projects.Project
  alias Thevis.Strategy.Playbook

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "campaigns" do
    field :name, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:draft, :active, :paused, :completed, :failed]

    field :campaign_type, Ecto.Enum,
      values: [:content, :authority, :consistency, :full, :product_launch]

    field :intensity, Ecto.Enum, values: [:standard, :high, :critical]
    field :launch_window_mode, :boolean, default: false
    field :goals, :map, default: %{}
    field :settings, :map, default: %{}
    field :started_at, :utc_datetime_usec
    field :completed_at, :utc_datetime_usec

    belongs_to :project, Project
    belongs_to :playbook, Playbook

    has_many :automation_results, Thevis.Automation.AutomationResult
    has_many :content_items, Thevis.Automation.ContentItem

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t() | nil,
          status: :draft | :active | :paused | :completed | :failed,
          campaign_type: :content | :authority | :consistency | :full | :product_launch,
          intensity: :standard | :high | :critical,
          launch_window_mode: boolean(),
          goals: map(),
          settings: map(),
          started_at: DateTime.t() | nil,
          completed_at: DateTime.t() | nil,
          project_id: binary(),
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          playbook_id: binary() | nil,
          playbook: Playbook.t() | Ecto.Association.NotLoaded.t(),
          automation_results:
            [Thevis.Automation.AutomationResult.t()] | Ecto.Association.NotLoaded.t(),
          content_items: [Thevis.Automation.ContentItem.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, [
      :name,
      :description,
      :status,
      :campaign_type,
      :intensity,
      :launch_window_mode,
      :goals,
      :settings,
      :started_at,
      :completed_at,
      :project_id,
      :playbook_id
    ])
    |> validate_required([:name, :status, :campaign_type, :intensity, :project_id])
    |> validate_length(:name, min: 1, max: 255)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:playbook_id)
  end
end

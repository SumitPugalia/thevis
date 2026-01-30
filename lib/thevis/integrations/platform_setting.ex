defmodule Thevis.Integrations.PlatformSetting do
  @moduledoc """
  PlatformSetting schema for storing platform-specific configuration.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "platform_settings" do
    field :platform_type, :string
    field :settings, :map, default: %{}
    field :is_active, :boolean, default: true

    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          project_id: binary(),
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          platform_type: String.t(),
          settings: map(),
          is_active: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @allowed_platforms [
    "github",
    "medium",
    "blog",
    "wordpress",
    "contentful",
    "g2",
    "capterra",
    "trustpilot",
    "google_business",
    "yelp",
    "crunchbase",
    "linkedin_company",
    "product_hunt",
    "clutch",
    "alternativeto",
    "twitter",
    "facebook",
    "reddit",
    "stack_overflow",
    "quora",
    "hacker_news"
  ]

  @doc false
  def changeset(platform_setting, attrs) do
    platform_setting
    |> cast(attrs, [:platform_type, :settings, :is_active, :project_id])
    |> validate_required([:platform_type, :project_id])
    |> validate_inclusion(:platform_type, @allowed_platforms)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:project_id, :platform_type])
  end
end

defmodule Thevis.Automation.ContentItem do
  @moduledoc """
  ContentItem schema representing individual content pieces created by automation.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Automation.Campaign
  alias Thevis.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "content_items" do
    field :content_type,
          Ecto.Enum,
          values: [:blog_post, :github_readme, :documentation, :article, :wiki_page]

    field :title, :string
    field :content, :string

    field :platform,
          Ecto.Enum,
          values: [:github, :medium, :blog, :docs, :wikipedia, :company_wiki]

    field :status, Ecto.Enum, values: [:draft, :scheduled, :published, :failed]
    field :published_url, :string
    field :ai_optimization_score, :float
    field :performance_metrics, :map, default: %{}
    field :scheduled_at, :utc_datetime_usec
    field :published_at, :utc_datetime_usec

    belongs_to :campaign, Campaign
    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          content_type: :blog_post | :github_readme | :documentation | :article | :wiki_page,
          title: String.t(),
          content: String.t(),
          platform: :github | :medium | :blog | :docs | :wikipedia | :company_wiki,
          status: :draft | :scheduled | :published | :failed,
          published_url: String.t() | nil,
          ai_optimization_score: float() | nil,
          performance_metrics: map(),
          scheduled_at: DateTime.t() | nil,
          published_at: DateTime.t() | nil,
          campaign_id: binary(),
          campaign: Campaign.t() | Ecto.Association.NotLoaded.t(),
          project_id: binary(),
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(content_item, attrs) do
    content_item
    |> cast(attrs, [
      :content_type,
      :title,
      :content,
      :platform,
      :status,
      :published_url,
      :ai_optimization_score,
      :performance_metrics,
      :scheduled_at,
      :published_at,
      :campaign_id,
      :project_id
    ])
    |> validate_required([
      :content_type,
      :title,
      :content,
      :platform,
      :status,
      :campaign_id,
      :project_id
    ])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:content, min: 10)
    |> foreign_key_constraint(:campaign_id)
    |> foreign_key_constraint(:project_id)
  end
end

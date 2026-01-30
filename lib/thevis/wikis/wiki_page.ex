defmodule Thevis.Wikis.WikiPage do
  @moduledoc """
  WikiPage schema representing wiki pages for projects.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Projects.Project
  alias Thevis.Wikis.WikiContent
  alias Thevis.Wikis.WikiPlatform

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_pages" do
    field :title, :string
    field :url, :string
    field :external_id, :string
    field :status, Ecto.Enum, values: [:draft, :published, :archived, :failed]
    field :page_type, Ecto.Enum, values: [:product, :company, :service]
    field :metadata, :map, default: %{}

    belongs_to :project, Project
    belongs_to :platform, WikiPlatform

    has_many :wiki_contents, WikiContent

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          title: String.t(),
          url: String.t() | nil,
          external_id: String.t() | nil,
          status: :draft | :published | :archived | :failed,
          page_type: :product | :company | :service,
          metadata: map(),
          project_id: binary(),
          project: Project.t() | Ecto.Association.NotLoaded.t(),
          platform_id: binary() | nil,
          platform: WikiPlatform.t() | Ecto.Association.NotLoaded.t(),
          wiki_contents: [WikiContent.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(wiki_page, attrs) do
    wiki_page
    |> cast(attrs, [
      :title,
      :url,
      :external_id,
      :status,
      :page_type,
      :metadata,
      :project_id,
      :platform_id
    ])
    |> validate_required([:title, :status, :page_type, :project_id])
    |> validate_length(:title, min: 1, max: 255)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:platform_id)
    |> unique_constraint([:platform_id, :external_id])
  end
end

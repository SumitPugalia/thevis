defmodule Thevis.Wikis.WikiContent do
  @moduledoc """
  WikiContent schema representing versions of wiki page content.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Wikis.WikiPage

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_contents" do
    field :content, :string
    field :version, :integer, default: 1
    field :is_published, :boolean, default: false
    field :published_at, :utc_datetime_usec
    field :metadata, :map, default: %{}

    belongs_to :wiki_page, WikiPage

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          content: String.t(),
          version: integer(),
          is_published: boolean(),
          published_at: DateTime.t() | nil,
          metadata: map(),
          wiki_page_id: binary(),
          wiki_page: WikiPage.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(wiki_content, attrs) do
    wiki_content
    |> cast(attrs, [:content, :version, :is_published, :published_at, :metadata, :wiki_page_id])
    |> validate_required([:content, :version, :wiki_page_id])
    |> validate_length(:content, min: 10)
    |> foreign_key_constraint(:wiki_page_id)
    |> unique_constraint([:wiki_page_id, :version])
  end
end

defmodule Thevis.Wikis.WikiPlatform do
  @moduledoc """
  WikiPlatform schema representing different wiki platforms.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_platforms" do
    field :name, :string
    field :platform_type, :string
    field :api_endpoint, :string
    field :api_key, :string, redact: true
    field :config, :map, default: %{}
    field :is_active, :boolean, default: true

    has_many :wiki_pages, Thevis.Wikis.WikiPage, foreign_key: :platform_id

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          platform_type: String.t(),
          api_endpoint: String.t() | nil,
          api_key: String.t() | nil,
          config: map(),
          is_active: boolean(),
          wiki_pages: [Thevis.Wikis.WikiPage.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(platform, attrs) do
    platform
    |> cast(attrs, [:name, :platform_type, :api_endpoint, :api_key, :config, :is_active])
    |> validate_required([:name, :platform_type])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_inclusion(:platform_type, ["wikipedia", "confluence", "notion", "custom"])
    |> unique_constraint(:name)
  end
end

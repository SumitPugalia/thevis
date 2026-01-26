defmodule Thevis.Accounts.Company do
  @moduledoc """
  Company schema representing client companies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "companies" do
    field :name, :string
    field :domain, :string
    field :industry, :string
    field :description, :string
    field :website_url, :string
    field :company_type, Ecto.Enum, values: [:product_based, :service_based]
    field :competitors, {:array, :map}, default: []

    has_many :roles, Thevis.Accounts.Role

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          domain: String.t(),
          industry: String.t(),
          description: String.t() | nil,
          website_url: String.t() | nil,
          company_type: :product_based | :service_based,
          competitors: [map()],
          roles: Ecto.Association.NotLoaded.t() | [Thevis.Accounts.Role.t()],
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [
      :name,
      :domain,
      :industry,
      :description,
      :website_url,
      :company_type,
      :competitors
    ])
    |> validate_required([:name, :domain, :industry, :company_type])
    |> validate_format(:domain, ~r/^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$/,
      message: "must be a valid domain"
    )
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:domain, min: 1, max: 255)
    |> validate_competitors()
    |> unsafe_validate_unique(:domain, Thevis.Repo)
    |> unique_constraint(:domain)
  end

  defp validate_competitors(changeset) do
    competitors = get_change(changeset, :competitors) || get_field(changeset, :competitors)

    if competitors && is_list(competitors) do
      validate_competitors_list(changeset, competitors)
    else
      changeset
    end
  end

  defp validate_competitors_list(changeset, competitors) do
    Enum.reduce(competitors, changeset, fn competitor, acc ->
      if is_map(competitor) do
        validate_competitor_fields(acc, competitor)
      else
        add_error(acc, :competitors, "must be a list of maps")
      end
    end)
  end

  defp validate_competitor_fields(changeset, competitor) do
    # Check for both atom and string keys
    has_name =
      (Map.has_key?(competitor, :name) && competitor[:name] != nil && competitor[:name] != "") ||
        (Map.has_key?(competitor, "name") && competitor["name"] != nil && competitor["name"] != "")

    has_domain =
      (Map.has_key?(competitor, :domain) && competitor[:domain] != nil &&
         competitor[:domain] != "") ||
        (Map.has_key?(competitor, "domain") && competitor["domain"] != nil &&
           competitor["domain"] != "")

    if has_name && has_domain do
      changeset
    else
      add_error(changeset, :competitors, "each competitor must have name and domain")
    end
  end
end

defmodule Thevis.Services.Service do
  @moduledoc """
  Service schema representing services that can be optimized for service-based companies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "services" do
    field :name, :string
    field :description, :string
    field :category, :string

    field :service_type, Ecto.Enum,
      values: [
        :consulting,
        :saas,
        :professional,
        :support,
        :education,
        :healthcare,
        :financial,
        :other
      ]

    belongs_to :company, Thevis.Accounts.Company

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [
      :name,
      :description,
      :category,
      :service_type,
      :company_id
    ])
    |> validate_required([:name, :service_type, :company_id])
    |> validate_length(:name, min: 1, max: 255)
    |> foreign_key_constraint(:company_id)
  end
end

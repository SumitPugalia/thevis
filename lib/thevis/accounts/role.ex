defmodule Thevis.Accounts.Role do
  @moduledoc """
  Role schema representing user-company relationships.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "roles" do
    field :role_type, Ecto.Enum, values: [:consultant, :client]

    belongs_to :user, Thevis.Accounts.User
    belongs_to :company, Thevis.Accounts.Company

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:role_type, :user_id, :company_id])
    |> validate_required([:role_type, :user_id, :company_id])
    |> unsafe_validate_unique([:user_id, :company_id], Thevis.Repo)
    |> unique_constraint([:user_id, :company_id])
  end
end

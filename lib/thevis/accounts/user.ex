defmodule Thevis.Accounts.User do
  @moduledoc """
  User schema for authentication and authorization.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :name, :string
    field :hashed_password, :string
    field :password, :string, virtual: true, redact: true
    field :role, Ecto.Enum, values: [:consultant, :client]
    field :logged_at, :utc_datetime_usec

    has_many :roles, Thevis.Accounts.Role

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  A user changeset for registration.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :name, :password, :role])
    |> validate_email()
    |> maybe_validate_password(opts)
    |> validate_required([:email, :name, :role])
  end

  @doc """
  A user changeset for updates (without password).
  """
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_email()
  end

  defp maybe_validate_password(changeset, opts) do
    if get_change(changeset, :password) do
      validate_password(changeset, opts)
    else
      changeset
    end
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Thevis.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.
  """
  def email_changeset(user, attrs) do
    changeset =
      user
      |> cast(attrs, [:email])
      |> validate_email()

    case changeset do
      %{changes: %{email: _}} -> changeset
      %{changes: _} -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.truncate(DateTime.utc_now(), :second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.
  """
  def valid_password?(%Thevis.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end

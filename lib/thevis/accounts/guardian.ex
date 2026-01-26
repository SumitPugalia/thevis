defmodule Thevis.Guardian do
  @moduledoc """
  Guardian implementation for JWT authentication.
  """

  use Guardian, otp_app: :thevis

  alias Thevis.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def build_claims(claims, _resource, _opts) do
    # Add created_at timestamp to claims for token validation
    created_at = DateTime.to_unix(DateTime.utc_now())
    claims = Map.put(claims, "created_at", created_at)
    {:ok, claims}
  end

  def resource_from_claims(%{"sub" => id} = claims) do
    case Accounts.get_user(id) do
      nil ->
        {:error, :resource_not_found}

      user ->
        # Validate token against logged_at
        if valid_token?(user, claims) do
          {:ok, user}
        else
          {:error, :token_invalidated}
        end
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_subject}
  end

  defp valid_token?(user, claims) do
    # Token is valid if:
    # 1. User has logged_at set (user has logged in at least once)
    # 2. Token's created_at is after user's logged_at (token was issued after last login)
    case {user.logged_at, Map.get(claims, "created_at")} do
      {nil, _} ->
        # User hasn't logged in yet, allow token (for first login)
        true

      {_logged_at, nil} ->
        # Token doesn't have created_at, consider it invalid
        false

      {logged_at, created_at_unix} ->
        # Convert logged_at to unix timestamp for comparison
        logged_at_unix = DateTime.to_unix(logged_at)
        # Token is valid if created_at >= logged_at (token was issued at or after last login)
        created_at_unix >= logged_at_unix
    end
  end
end

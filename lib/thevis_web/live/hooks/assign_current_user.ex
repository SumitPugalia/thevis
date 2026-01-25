defmodule ThevisWeb.Live.Hooks.AssignCurrentUser do
  @moduledoc """
  LiveView on_mount hook to assign current_user from session token to socket.
  """

  import Phoenix.LiveView
  import Phoenix.Component
  alias Thevis.Guardian

  def on_mount(:assign_current_user, _params, session, socket) do
    # Get token from session
    token = Map.get(session, "guardian_default_token")

    IO.inspect(token != nil, label: "ON_MOUNT - Token in session")

    if token do
      # Decode and verify the token
      case Guardian.decode_and_verify(token) do
        {:ok, claims} ->
          # Get user from claims
          case Guardian.resource_from_claims(claims) do
            {:ok, user} ->
              IO.inspect(user.id, label: "ON_MOUNT - User loaded from token")
              {:cont, assign(socket, :current_user, user)}

            {:error, reason} ->
              IO.inspect(reason, label: "ON_MOUNT - Failed to load user from claims")
              {:cont, assign(socket, :current_user, nil)}
          end

        {:error, reason} ->
          IO.inspect(reason, label: "ON_MOUNT - Failed to decode token")
          {:cont, assign(socket, :current_user, nil)}
      end
    else
      IO.inspect("ON_MOUNT - No token in session", label: "AUTH")
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end

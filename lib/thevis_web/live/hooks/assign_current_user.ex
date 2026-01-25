defmodule ThevisWeb.Live.Hooks.AssignCurrentUser do
  @moduledoc """
  LiveView on_mount hook to assign current_user from session token to socket.
  """

  import Phoenix.Component
  alias Thevis.Guardian

  def on_mount(:assign_current_user, _params, session, socket) do
    # Get token from session
    token = Map.get(session, "guardian_default_token")

    if token do
      # Decode and verify the token
      case Guardian.decode_and_verify(token) do
        {:ok, claims} ->
          # Get user from claims
          case Guardian.resource_from_claims(claims) do
            {:ok, user} ->
              {:cont, assign(socket, :current_user, user)}

            {:error, _reason} ->
              {:cont, assign(socket, :current_user, nil)}
          end

        {:error, _reason} ->
          {:cont, assign(socket, :current_user, nil)}
      end
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end

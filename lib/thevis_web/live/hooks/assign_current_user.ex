defmodule ThevisWeb.Live.Hooks.AssignCurrentUser do
  @moduledoc """
  LiveView on_mount hook to assign current_user from session token to socket.
  """

  import Phoenix.Component
  alias Thevis.Guardian

  def on_mount(:assign_current_user, _params, session, socket) do
    # Get token from session
    token = Map.get(session, "guardian_default_token")

    current_user = get_user_from_token(token)
    {:cont, assign(socket, :current_user, current_user)}
  end

  defp get_user_from_token(nil), do: nil

  defp get_user_from_token(token) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} -> user
          {:error, _reason} -> nil
        end

      {:error, _reason} ->
        nil
    end
  end
end

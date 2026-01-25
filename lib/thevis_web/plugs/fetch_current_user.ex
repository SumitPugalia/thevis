defmodule ThevisWeb.Plugs.FetchCurrentUser do
  @moduledoc """
  Plug to fetch current user from Guardian JWT token (optional, doesn't require auth).
  """

  import Plug.Conn
  alias Thevis.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    # Check if token exists in session
    session_token = get_session(conn, "guardian_default_token")
    IO.inspect(session_token != nil, label: "FETCH USER - Token in session")

    # Guardian.Plug.LoadResource should have loaded it
    token = Guardian.Plug.current_token(conn)
    IO.inspect(token != nil, label: "FETCH USER - Token in conn")

    resource = Guardian.Plug.current_resource(conn)
    IO.inspect(resource != nil, label: "FETCH USER - Resource exists")

    case resource do
      nil ->
        IO.inspect("FETCH USER - No current user found", label: "AUTH")
        assign(conn, :current_user, nil)

      user ->
        IO.inspect(user.id, label: "FETCH USER - Found user ID")
        assign(conn, :current_user, user)
    end
  end
end

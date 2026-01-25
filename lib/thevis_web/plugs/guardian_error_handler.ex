defmodule ThevisWeb.Plugs.GuardianErrorHandler do
  @moduledoc """
  Error handler for Guardian authentication failures.
  """

  import Plug.Conn
  import Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, reason}, _opts) do
    IO.inspect({type, reason}, label: "GUARDIAN ERROR - Auth failed")

    # Log additional debugging info
    token = Guardian.Plug.current_token(conn)
    resource = Guardian.Plug.current_resource(conn)
    IO.inspect(token != nil, label: "GUARDIAN ERROR - Token exists")
    IO.inspect(resource != nil, label: "GUARDIAN ERROR - Resource exists")

    conn
    |> put_flash(:error, "You must log in to access this page.")
    |> redirect(to: "/login")
    |> halt()
  end
end

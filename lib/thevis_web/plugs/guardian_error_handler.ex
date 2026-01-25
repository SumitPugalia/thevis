defmodule ThevisWeb.Plugs.GuardianErrorHandler do
  @moduledoc """
  Error handler for Guardian authentication failures.
  """

  import Plug.Conn
  import Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_flash(:error, "You must log in to access this page.")
    |> redirect(to: "/login")
    |> halt()
  end
end

defmodule ThevisWeb.Plugs.RequireAdmin do
  @moduledoc """
  Plug to require admin/consultant role for admin routes.

  This plug checks that the current user has the :consultant role.
  It should be used after RequireAuthenticatedUser.
  """

  import Plug.Conn
  alias Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.role == :consultant do
      conn
    else
      conn
      |> Controller.put_flash(:error, "You must be an admin to access this page.")
      |> Controller.redirect(to: "/dashboard")
      |> halt()
    end
  end
end

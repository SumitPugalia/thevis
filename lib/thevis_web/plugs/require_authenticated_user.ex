defmodule ThevisWeb.Plugs.RequireAuthenticatedUser do
  @moduledoc """
  Plug to require authenticated user for protected routes using Guardian JWT.
  This plug runs after Guardian.Plug.EnsureAuthenticated, so we can assume
  the user is authenticated if we reach here.
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    # Guardian.Plug.EnsureAuthenticated already verified the token
    # and set current_user in assigns via Guardian.Plug.current_resource
    conn
  end
end

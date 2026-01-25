defmodule ThevisWeb.Plugs.RequireAuthenticatedUser do
  @moduledoc """
  Plug to require authenticated user for protected routes using Guardian JWT.
  This plug runs after Guardian.Plug.EnsureAuthenticated, so we can assume
  the user is authenticated if we reach here.
  """

  import Plug.Conn
  alias Thevis.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    # Guardian.Plug.EnsureAuthenticated already verified the token
    # Ensure current_user is set from Guardian resource
    resource = Guardian.Plug.current_resource(conn)

    if resource do
      assign(conn, :current_user, resource)
    else
      conn
    end
  end
end

defmodule ThevisWeb.Plugs.FetchCurrentUser do
  @moduledoc """
  Plug to fetch current user from Guardian JWT token (optional, doesn't require auth).
  """

  import Plug.Conn
  alias Thevis.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        assign(conn, :current_user, nil)

      user ->
        assign(conn, :current_user, user)
    end
  end
end

defmodule ThevisWeb.PageController do
  use ThevisWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/dashboard")
    else
      redirect(conn, to: ~p"/login")
    end
  end
end

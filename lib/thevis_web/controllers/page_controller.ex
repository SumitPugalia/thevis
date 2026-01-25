defmodule ThevisWeb.PageController do
  use ThevisWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

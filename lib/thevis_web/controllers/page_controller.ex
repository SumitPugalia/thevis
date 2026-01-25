defmodule ThevisWeb.PageController do
  use ThevisWeb, :controller

  def home(conn, _params) do
    # Always show landing page, users can navigate to login/register from there
    redirect(conn, to: ~p"/")
  end
end

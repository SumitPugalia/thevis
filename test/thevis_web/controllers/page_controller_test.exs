defmodule ThevisWeb.PageControllerTest do
  use ThevisWeb.ConnCase

  test "GET / redirects to companies", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Companies"
  end
end

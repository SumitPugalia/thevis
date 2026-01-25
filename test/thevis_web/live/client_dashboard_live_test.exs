defmodule ThevisWeb.ClientDashboardLiveTest do
  @moduledoc """
  Tests for client dashboard LiveView.
  """

  use ThevisWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Thevis.Accounts

  describe "Dashboard access" do
    test "redirects to login when not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/dashboard")
      assert redirected_to(conn) == ~p"/login"
    end

    test "shows dashboard when authenticated", %{conn: conn} do
      # Create a user
      {:ok, _user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      # Sign in via login endpoint to properly set up session
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "client@example.com", "password" => "password1234"}
        })

      # Follow redirect to dashboard
      assert redirected_to(conn) == ~p"/dashboard"
      conn = get(conn, ~p"/dashboard")

      # Should render the dashboard
      assert html_response(conn, 200) =~ "Dashboard"
      assert html_response(conn, 200) =~ "Welcome back"
    end

    test "displays empty state when user has no companies", %{conn: conn} do
      # Create a user
      {:ok, _user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      # Sign in via login endpoint to properly set up session
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "client@example.com", "password" => "password1234"}
        })

      # Follow redirect
      assert redirected_to(conn) == ~p"/dashboard"

      # Now test LiveView
      {:ok, _index_live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Dashboard"
      assert html =~ "Welcome back"
      assert html =~ "No companies yet"
    end
  end
end

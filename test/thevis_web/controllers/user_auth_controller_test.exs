defmodule ThevisWeb.UserAuthControllerTest do
  @moduledoc """
  Tests for user authentication controller.
  """

  use ThevisWeb.ConnCase

  alias Thevis.Accounts

  describe "POST /login" do
    test "redirects to dashboard when credentials are valid for client", %{conn: conn} do
      {:ok, _user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "client@example.com", "password" => "password1234"}
        })

      assert redirected_to(conn) == ~p"/dashboard"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "redirects to admin when credentials are valid for consultant", %{conn: conn} do
      {:ok, _user} =
        Accounts.create_user(%{
          email: "consultant@example.com",
          name: "Test Consultant",
          password: "password1234",
          role: :consultant
        })

      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "consultant@example.com", "password" => "password1234"}
        })

      assert redirected_to(conn) == ~p"/companies"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "redirects to login with error when credentials are invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "wrong@example.com", "password" => "wrongpassword"}
        })

      assert redirected_to(conn) == ~p"/login"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid email or password"
    end
  end

  describe "DELETE /logout" do
    test "logs out the user and redirects to home", %{conn: conn} do
      {:ok, _user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      # Sign in first
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "client@example.com", "password" => "password1234"}
        })

      # Then log out
      logout_conn = delete(conn, ~p"/logout")

      assert redirected_to(logout_conn) == ~p"/"
      assert Phoenix.Flash.get(logout_conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end

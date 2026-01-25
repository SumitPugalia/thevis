defmodule ThevisWeb.UserRegistrationLiveTest do
  @moduledoc """
  Tests for user registration LiveView.
  """

  use ThevisWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Thevis.Accounts

  describe "Registration" do
    test "renders registration form", %{conn: conn} do
      {:ok, registration_live, html} = live(conn, ~p"/register")

      assert html =~ "Create Account"
      assert html =~ "Sign up to get started with thevis.ai"
      assert has_element?(registration_live, "input[name='user[name]']")
      assert has_element?(registration_live, "input[name='user[email]']")
      assert has_element?(registration_live, "input[name='user[password]']")
      assert has_element?(registration_live, "input[name='terms']")
    end

    test "creates account when form is valid and terms are accepted", %{conn: conn} do
      {:ok, registration_live, _html} = live(conn, ~p"/register")

      assert registration_live
             |> form("#registration-form", %{
               "user" => %{
                 "name" => "Test User",
                 "email" => "test@example.com",
                 "password" => "password1234"
               },
               "terms" => "true"
             })
             |> render_submit()

      # Should redirect to login
      assert_redirect(registration_live, ~p"/login")

      # Verify user was created
      user = Accounts.get_user_by_email("test@example.com")
      assert user
      assert user.role == :client
    end

    test "shows error when terms are not accepted", %{conn: conn} do
      {:ok, registration_live, _html} = live(conn, ~p"/register")

      result =
        registration_live
        |> form("#registration-form", %{
          "user" => %{
            "name" => "Test User",
            "email" => "test@example.com",
            "password" => "password1234"
          }
          # terms not included
        })
        |> render_submit()

      assert result =~ "Please accept the Terms of Service"
    end

    test "validates email format", %{conn: conn} do
      {:ok, registration_live, _html} = live(conn, ~p"/register")

      result =
        registration_live
        |> form("#registration-form", %{
          "user" => %{
            "name" => "Test User",
            "email" => "invalid-email",
            "password" => "password1234"
          },
          "terms" => "true"
        })
        |> render_change()

      assert result =~ "must have the @ sign"
    end

    test "validates password length", %{conn: conn} do
      {:ok, registration_live, _html} = live(conn, ~p"/register")

      result =
        registration_live
        |> form("#registration-form", %{
          "user" => %{
            "name" => "Test User",
            "email" => "test@example.com",
            "password" => "short"
          },
          "terms" => "true"
        })
        |> render_change()

      assert result =~ "should be at least"
    end
  end
end

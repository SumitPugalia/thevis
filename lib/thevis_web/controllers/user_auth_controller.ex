defmodule ThevisWeb.UserAuthController do
  @moduledoc """
  Controller for handling user authentication (login/logout) with Guardian JWT.
  """

  use ThevisWeb, :controller

  alias Thevis.Accounts
  alias Thevis.Guardian

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    create(conn, params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    case Accounts.get_user_by_email_and_password(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, info)
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: "/dashboard")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, email)
        |> redirect(to: "/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end

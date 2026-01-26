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
        redirect_to = get_redirect_path(user)

        # Update logged_at timestamp before signing in
        {:ok, updated_user} = Accounts.update_logged_at(user)

        conn
        |> Guardian.Plug.sign_in(updated_user)
        |> put_flash(:info, info)
        |> redirect(to: redirect_to)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, email)
        |> redirect(to: "/login")
    end
  end

  defp get_redirect_path(%{role: :consultant}), do: "/companies"
  defp get_redirect_path(%{role: :client}), do: "/dashboard"
  defp get_redirect_path(_), do: "/dashboard"

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end

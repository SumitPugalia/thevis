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

    IO.inspect(email, label: "LOGIN ATTEMPT - Email")

    case Accounts.get_user_by_email_and_password(email, password) do
      {:ok, user} ->
        IO.inspect(user.id, label: "LOGIN SUCCESS - User ID")
        redirect_to = get_redirect_path(user)
        IO.inspect(redirect_to, label: "LOGIN SUCCESS - Redirecting to")

        # Sign in with Guardian - use default key
        conn = Guardian.Plug.sign_in(conn, user)

        # Verify token was set
        token = Guardian.Plug.current_token(conn)
        IO.inspect(token != nil, label: "LOGIN SUCCESS - Token exists in conn")

        # Get the resource to verify
        resource = Guardian.Plug.current_resource(conn)
        IO.inspect(resource != nil, label: "LOGIN SUCCESS - Resource exists in conn")

        conn
        |> put_flash(:info, info)
        |> redirect(to: redirect_to)

      {:error, reason} ->
        IO.inspect(reason, label: "LOGIN FAILED - Invalid credentials")

        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, email)
        |> redirect(to: "/login")
    end
  end

  defp get_redirect_path(%{role: :consultant}), do: "/admin/companies"
  defp get_redirect_path(%{role: :client}), do: "/dashboard"
  defp get_redirect_path(_), do: "/dashboard"

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end

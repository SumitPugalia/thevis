defmodule Thevis.Accounts.AuthenticationTest do
  @moduledoc """
  Tests for authentication functionality.
  """

  use Thevis.DataCase

  alias Thevis.Accounts

  describe "get_user_by_email_and_password/2" do
    test "returns user when email and password are valid" do
      {:ok, user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      assert {:ok, authenticated_user} =
               Accounts.get_user_by_email_and_password("client@example.com", "password1234")

      assert authenticated_user.id == user.id
    end

    test "returns error when email is invalid" do
      assert {:error, :invalid_credentials} =
               Accounts.get_user_by_email_and_password("wrong@example.com", "password1234")
    end

    test "returns error when password is invalid" do
      {:ok, _user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      assert {:error, :invalid_credentials} =
               Accounts.get_user_by_email_and_password("client@example.com", "wrongpassword")
    end
  end
end

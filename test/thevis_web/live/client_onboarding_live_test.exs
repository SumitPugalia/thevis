defmodule ThevisWeb.ClientOnboardingLiveTest do
  use ThevisWeb.ConnCase

  import Phoenix.LiveViewTest
  import Thevis.Factory

  alias Thevis.Accounts

  setup %{conn: conn} do
    user = insert(:user, role: :client, hashed_password: Bcrypt.hash_pwd_salt("password123456"))

    conn =
      post(conn, ~p"/login", %{"user" => %{"email" => user.email, "password" => "password123456"}})

    {:ok, conn: conn, user: user}
  end

  describe "Company creation" do
    test "creates company and assigns owner role", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/onboarding")

      company_params = %{
        "company" => %{
          "name" => "Test Company",
          "domain" => "testcompany.com",
          "industry" => "Technology",
          "website_url" => "https://testcompany.com",
          "description" => "A test company",
          "company_type" => "product_based"
        }
      }

      html =
        view
        |> element("#company-form")
        |> render_submit(company_params)

      assert html =~ "Products/Services"

      # Verify company was created
      companies = Accounts.list_companies()
      company = Enum.find(companies, &(&1.domain == "testcompany.com"))
      assert company.name == "Test Company"
      assert company.company_type == :product_based

      # Verify role was assigned
      user = Accounts.get_user(user.id) |> Thevis.Repo.preload(:roles)
      role = Enum.find(user.roles, &(&1.company_id == company.id))
      assert role.role_type == :owner
    end

    test "shows validation errors for invalid company data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/onboarding")

      invalid_params = %{
        "company" => %{
          "name" => "",
          "domain" => "",
          "industry" => "",
          "company_type" => "product_based"
        }
      }

      html =
        view
        |> element("#company-form")
        |> render_submit(invalid_params)

      assert html =~ "can&#39;t be blank"
    end

    test "prevents duplicate domain", %{conn: conn} do
      # Create a company with existing domain
      {:ok, _existing_company} =
        Accounts.create_company(%{
          name: "Existing Company",
          domain: "existing.com",
          industry: "Technology",
          company_type: :product_based
        })

      {:ok, view, _html} = live(conn, ~p"/onboarding")

      duplicate_params = %{
        "company" => %{
          "name" => "New Company",
          "domain" => "existing.com",
          "industry" => "Technology",
          "website_url" => "https://existing.com",
          "description" => "A new company",
          "company_type" => "product_based"
        }
      }

      html =
        view
        |> element("#company-form")
        |> render_submit(duplicate_params)

      assert html =~ "has already been taken"
    end
  end
end

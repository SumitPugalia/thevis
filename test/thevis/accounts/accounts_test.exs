defmodule Thevis.AccountsTest do
  @moduledoc """
  Tests for Accounts context following TDD principles.
  """

  use Thevis.DataCase

  alias Thevis.Accounts
  alias Thevis.Accounts.Company
  alias Thevis.Accounts.Role
  alias Thevis.Accounts.User

  describe "users" do
    @valid_attrs %{
      email: "user@example.com",
      name: "Test User",
      password: "password1234",
      role: :client
    }
    @update_attrs %{
      email: "updated@example.com",
      name: "Updated User"
    }
    @invalid_attrs %{email: nil, name: nil, password: nil}

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "user@example.com"
      assert user.name == "Test User"
      assert user.role == :client
      assert Bcrypt.verify_pass("password1234", user.hashed_password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with duplicate email returns error changeset" do
      {:ok, _user} = Accounts.create_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{errors: errors}} = Accounts.create_user(@valid_attrs)
      assert errors[:email] != nil
    end

    test "update_user/2 with valid data updates the user" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, @update_attrs)
      assert updated_user.email == "updated@example.com"
      assert updated_user.name == "Updated User"
    end

    test "update_user/2 with invalid data returns error changeset" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "get_user/1 returns the user with given id" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert Accounts.get_user(user.id).id == user.id
    end

    test "get_user!/1 returns the user with given id" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "get_user!/1 raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(Ecto.UUID.generate())
      end
    end

    test "list_users/0 returns all users" do
      {:ok, user1} = Accounts.create_user(@valid_attrs)
      user2_attrs = Map.put(@valid_attrs, :email, "user2@example.com")
      {:ok, _user2} = Accounts.create_user(user2_attrs)

      users = Accounts.list_users()
      assert length(users) >= 2
      assert user1 in users
    end

    test "list_users/1 with role filter returns filtered users" do
      {:ok, _client} = Accounts.create_user(@valid_attrs)

      consultant_attrs =
        Map.merge(@valid_attrs, %{email: "consultant@example.com", role: :consultant})

      {:ok, _consultant} = Accounts.create_user(consultant_attrs)

      clients = Accounts.list_users(role: :client)
      assert Enum.all?(clients, &(&1.role == :client))
    end
  end

  describe "companies" do
    @valid_attrs %{
      name: "Test Company",
      domain: "testcompany.com",
      industry: "Technology",
      description: "A test company",
      website_url: "https://testcompany.com",
      company_type: :product_based
    }
    @update_attrs %{
      name: "Updated Company",
      description: "Updated description"
    }
    @invalid_attrs %{name: nil, domain: nil, company_type: nil}

    test "create_company/1 with valid data creates a company" do
      assert {:ok, %Company{} = company} = Accounts.create_company(@valid_attrs)
      assert company.name == "Test Company"
      assert company.domain == "testcompany.com"
      assert company.industry == "Technology"
      assert company.company_type == :product_based
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      {:ok, company} = Accounts.create_company(@valid_attrs)
      assert {:ok, %Company{} = updated_company} = Accounts.update_company(company, @update_attrs)
      assert updated_company.name == "Updated Company"
      assert updated_company.description == "Updated description"
    end

    test "update_company/2 with invalid data returns error changeset" do
      {:ok, company} = Accounts.create_company(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_company(company, @invalid_attrs)
      assert company == Accounts.get_company!(company.id)
    end

    test "get_company/1 returns the company with given id" do
      {:ok, company} = Accounts.create_company(@valid_attrs)
      assert Accounts.get_company(company.id).id == company.id
    end

    test "get_company!/1 returns the company with given id" do
      {:ok, company} = Accounts.create_company(@valid_attrs)
      assert Accounts.get_company!(company.id).id == company.id
    end

    test "list_companies/0 returns all companies" do
      {:ok, company1} = Accounts.create_company(@valid_attrs)

      company2_attrs = Map.merge(@valid_attrs, %{name: "Company 2", domain: "company2.com"})

      {:ok, _company2} = Accounts.create_company(company2_attrs)

      companies = Accounts.list_companies()
      assert length(companies) >= 2
      assert company1 in companies
    end

    test "list_companies/1 with company_type filter returns filtered companies" do
      {:ok, _product_company} = Accounts.create_company(@valid_attrs)

      service_company_attrs =
        Map.merge(@valid_attrs, %{
          name: "Service Co",
          domain: "service.com",
          company_type: :service_based
        })

      {:ok, _service_company} = Accounts.create_company(service_company_attrs)

      product_companies = Accounts.list_companies(company_type: :product_based)
      assert Enum.all?(product_companies, &(&1.company_type == :product_based))
    end
  end

  describe "competitors" do
    test "add_competitor/2 adds a competitor to the company's competitors array" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Main Company",
          domain: "main.com",
          industry: "Tech",
          company_type: :product_based
        })

      competitor_attrs = %{
        name: "Competitor",
        domain: "competitor.com",
        industry: "Tech"
      }

      assert {:ok, updated_company} = Accounts.add_competitor(company, competitor_attrs)
      competitors = Accounts.list_competitors(updated_company)
      assert length(competitors) == 1
      assert Enum.at(competitors, 0)["name"] == "Competitor"
      assert Enum.at(competitors, 0)["domain"] == "competitor.com"
    end

    test "list_competitors/1 returns all competitors for a company" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Main Company",
          domain: "main.com",
          industry: "Tech",
          company_type: :product_based
        })

      {:ok, company_with_comp1} =
        Accounts.add_competitor(company, %{name: "Comp1", domain: "comp1.com", industry: "Tech"})

      {:ok, company_with_comp2} =
        Accounts.add_competitor(company_with_comp1, %{
          name: "Comp2",
          domain: "comp2.com",
          industry: "Tech"
        })

      competitors = Accounts.list_competitors(company_with_comp2)
      assert length(competitors) == 2
    end

    test "remove_competitor/2 removes a competitor by index" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Main Company",
          domain: "main.com",
          industry: "Tech",
          company_type: :product_based
        })

      {:ok, company_with_competitor} =
        Accounts.add_competitor(company, %{
          name: "Competitor",
          domain: "comp.com",
          industry: "Tech"
        })

      assert length(Accounts.list_competitors(company_with_competitor)) == 1

      assert {:ok, updated_company} = Accounts.remove_competitor(company_with_competitor, 0)
      competitors = Accounts.list_competitors(updated_company)
      assert competitors == []
    end

    test "remove_competitor/2 returns error for invalid index" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Main Company",
          domain: "main.com",
          industry: "Tech",
          company_type: :product_based
        })

      assert {:error, :not_found} = Accounts.remove_competitor(company, 999)
    end

    test "update_competitor/3 updates a competitor by index" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Main Company",
          domain: "main.com",
          industry: "Tech",
          company_type: :product_based
        })

      {:ok, company_with_competitor} =
        Accounts.add_competitor(company, %{
          name: "Competitor",
          domain: "comp.com",
          industry: "Tech"
        })

      assert {:ok, updated_company} =
               Accounts.update_competitor(company_with_competitor, 0, %{
                 "name" => "Updated Competitor"
               })

      competitors = Accounts.list_competitors(updated_company)
      assert Enum.at(competitors, 0)["name"] == "Updated Competitor"
    end

    test "update_competitor/3 returns error for invalid index" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Main Company",
          domain: "main.com",
          industry: "Tech",
          company_type: :product_based
        })

      assert {:error, :not_found} = Accounts.update_competitor(company, 999, %{name: "Updated"})
    end
  end

  describe "roles" do
    test "assign_role/3 creates a role relationship" do
      {:ok, user} =
        Accounts.create_user(%{
          email: "user@example.com",
          name: "User",
          password: "password1234",
          role: :client
        })

      {:ok, company} =
        Accounts.create_company(%{
          name: "Company",
          domain: "company.com",
          industry: "Tech",
          company_type: :product_based
        })

      assert {:ok, %Role{} = role} = Accounts.assign_role(user, company, :client)
      assert role.user_id == user.id
      assert role.company_id == company.id
      assert role.role_type == :client
    end

    test "assign_role/3 with consultant role creates consultant role" do
      {:ok, user} =
        Accounts.create_user(%{
          email: "consultant@example.com",
          name: "Consultant",
          password: "password1234",
          role: :consultant
        })

      {:ok, company} =
        Accounts.create_company(%{
          name: "Company",
          domain: "company.com",
          industry: "Tech",
          company_type: :product_based
        })

      assert {:ok, %Role{} = role} = Accounts.assign_role(user, company, :consultant)
      assert role.role_type == :consultant
    end
  end
end

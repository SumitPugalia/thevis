defmodule Thevis.ProjectsTest do
  @moduledoc """
  Tests for Projects context following TDD principles.
  """

  use Thevis.DataCase

  alias Thevis.Accounts
  alias Thevis.Products
  alias Thevis.Projects
  alias Thevis.Projects.Project

  describe "projects for products" do
    setup do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Product Company",
          domain: "product.com",
          industry: "Tech",
          company_type: :product_based
        })

      {:ok, product} =
        Products.create_product(company, %{
          name: "Test Product",
          description: "A test product",
          category: "cosmetics",
          product_type: :cosmetic
        })

      %{company: company, product: product}
    end

    @valid_attrs %{
      name: "Test Project",
      description: "A test project",
      status: :active,
      scan_frequency: :weekly,
      project_type: :ongoing_monitoring,
      urgency_level: :standard
    }
    @update_attrs %{
      name: "Updated Project",
      description: "Updated description"
    }
    @invalid_attrs %{name: nil, project_type: nil}

    test "create_project_for_product/2 with valid data creates a project", %{product: product} do
      assert {:ok, %Project{} = project} =
               Projects.create_project_for_product(product, @valid_attrs)

      assert project.name == "Test Project"
      assert project.optimizable_type == :product
      assert project.optimizable_id == product.id
      assert project.project_type == :ongoing_monitoring
      assert project.is_category_project == false
    end

    test "create_project_for_product/2 with product_launch type creates launch project", %{
      product: product
    } do
      attrs =
        Map.merge(@valid_attrs, %{
          project_type: :product_launch,
          urgency_level: :critical
        })

      assert {:ok, %Project{} = project} = Projects.create_project_for_product(product, attrs)
      assert project.project_type == :product_launch
      assert project.urgency_level == :critical
    end

    test "create_project_for_product/2 with invalid data returns error changeset", %{
      product: product
    } do
      assert {:error, %Ecto.Changeset{}} =
               Projects.create_project_for_product(product, @invalid_attrs)
    end

    test "update_project/2 with valid data updates the project", %{product: product} do
      {:ok, project} = Projects.create_project_for_product(product, @valid_attrs)
      assert {:ok, %Project{} = updated_project} = Projects.update_project(project, @update_attrs)
      assert updated_project.name == "Updated Project"
    end

    test "get_project/1 returns the project with given id", %{product: product} do
      {:ok, project} = Projects.create_project_for_product(product, @valid_attrs)
      assert Projects.get_project(project.id).id == project.id
    end

    test "list_projects_for_product/1 returns all projects for a product", %{product: product} do
      {:ok, project1} = Projects.create_project_for_product(product, @valid_attrs)

      {:ok, _project2} =
        Projects.create_project_for_product(
          product,
          Map.merge(@valid_attrs, %{name: "Project 2"})
        )

      projects = Projects.list_projects_for_product(product)
      assert length(projects) == 2
      assert project1 in projects
    end
  end

  describe "projects for services" do
    setup do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Service Company",
          domain: "service.com",
          industry: "Services",
          company_type: :service_based
        })

      %{company: company}
    end

    @valid_attrs %{
      name: "Service Project",
      description: "A service optimization project",
      status: :active,
      scan_frequency: :monthly,
      project_type: :ongoing_monitoring,
      urgency_level: :standard
    }

    test "create_project_for_service/2 creates a project for service-based company", %{
      company: company
    } do
      assert {:ok, %Project{} = project} =
               Projects.create_project_for_service(company, @valid_attrs)

      assert project.name == "Service Project"
      assert project.optimizable_type == :service
      assert project.optimizable_id == company.id
      assert project.project_type == :ongoing_monitoring
    end

    test "list_projects_for_service/1 returns all projects for a service", %{company: company} do
      {:ok, project1} = Projects.create_project_for_service(company, @valid_attrs)

      {:ok, _project2} =
        Projects.create_project_for_service(
          company,
          Map.merge(@valid_attrs, %{name: "Service Project 2"})
        )

      projects = Projects.list_projects_for_service(company)
      assert length(projects) == 2
      assert project1 in projects
    end
  end

  describe "list_projects_by_company/1" do
    test "returns all projects for a product-based company (products and their projects)" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Product Company",
          domain: "product.com",
          industry: "Tech",
          company_type: :product_based
        })

      {:ok, product1} =
        Products.create_product(company, %{
          name: "Product 1",
          category: "cosmetics",
          product_type: :cosmetic
        })

      {:ok, product2} =
        Products.create_product(company, %{
          name: "Product 2",
          category: "cosmetics",
          product_type: :cosmetic
        })

      {:ok, _project1} =
        Projects.create_project_for_product(product1, %{
          name: "Project 1",
          status: :active,
          scan_frequency: :weekly,
          project_type: :ongoing_monitoring,
          urgency_level: :standard
        })

      {:ok, _project2} =
        Projects.create_project_for_product(product2, %{
          name: "Project 2",
          status: :active,
          scan_frequency: :weekly,
          project_type: :ongoing_monitoring,
          urgency_level: :standard
        })

      projects = Projects.list_projects_by_company(company)
      assert length(projects) == 2
    end

    test "returns all projects for a service-based company" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Service Company",
          domain: "service.com",
          industry: "Services",
          company_type: :service_based
        })

      {:ok, _project1} =
        Projects.create_project_for_service(company, %{
          name: "Service Project 1",
          status: :active,
          scan_frequency: :monthly,
          project_type: :ongoing_monitoring,
          urgency_level: :standard
        })

      {:ok, _project2} =
        Projects.create_project_for_service(company, %{
          name: "Service Project 2",
          status: :active,
          scan_frequency: :monthly,
          project_type: :ongoing_monitoring,
          urgency_level: :standard
        })

      projects = Projects.list_projects_by_company(company)
      assert length(projects) == 2
    end
  end
end

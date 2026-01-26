defmodule Thevis.ProjectsTest do
  @moduledoc """
  Tests for Projects context following TDD principles.
  """

  use Thevis.DataCase

  alias Thevis.Accounts
  alias Thevis.Products
  alias Thevis.Projects
  alias Thevis.Projects.Project

  defp setup_company_and_product do
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

  describe "projects for products" do
    setup do
      setup_company_and_product()
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
      assert project.product_id == product.id
      assert project.project_type == :ongoing_monitoring
      assert project.is_category_project == false
    end

    test "create_project_for_product/2 with product_launch type creates launch project", %{
      product: product
    } do
      launch_attrs =
        Map.merge(@valid_attrs, %{project_type: :product_launch, urgency_level: :critical})

      assert {:ok, %Project{} = project} =
               Projects.create_project_for_product(product, launch_attrs)

      assert project.project_type == :product_launch
      assert project.urgency_level == :critical
    end

    test "create_project_for_product/2 with invalid data returns error changeset", %{
      product: product
    } do
      assert {:error, %Ecto.Changeset{}} =
               Projects.create_project_for_product(product, @invalid_attrs)
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
          description: "A product",
          category: "cosmetics",
          product_type: :cosmetic
        })

      {:ok, product2} =
        Products.create_product(company, %{
          name: "Product 2",
          description: "Another product",
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
  end

  describe "update_project/2" do
    setup do
      %{product: product} = setup_company_and_product()

      {:ok, project} =
        Projects.create_project_for_product(product, %{
          name: "Test Project",
          description: "A test project",
          status: :active,
          scan_frequency: :weekly,
          project_type: :ongoing_monitoring,
          urgency_level: :standard
        })

      %{project: project}
    end

    @update_attrs %{
      name: "Updated Project",
      description: "Updated description"
    }
    @invalid_attrs %{name: nil}

    test "update_project/2 with valid data updates the project", %{project: project} do
      assert {:ok, %Project{} = project} = Projects.update_project(project, @update_attrs)
      assert project.name == "Updated Project"
      assert project.description == "Updated description"
    end

    test "update_project/2 with invalid data returns error changeset", %{project: project} do
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end
  end

  describe "delete_project/1" do
    setup do
      %{product: product} = setup_company_and_product()

      {:ok, project} =
        Projects.create_project_for_product(product, %{
          name: "Test Project",
          description: "A test project",
          status: :active,
          scan_frequency: :weekly,
          project_type: :ongoing_monitoring,
          urgency_level: :standard
        })

      %{project: project}
    end

    test "delete_project/1 deletes the project", %{project: project} do
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end
  end
end

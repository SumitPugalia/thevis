defmodule Thevis.ProductsTest do
  @moduledoc """
  Tests for Products context following TDD principles.
  """

  use Thevis.DataCase

  alias Thevis.Products
  alias Thevis.Products.{Product, CompetitorProduct}
  alias Thevis.Accounts

  describe "products" do
    setup do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Test Company",
          domain: "testcompany.com",
          industry: "Technology",
          company_type: :product_based
        })

      %{company: company}
    end

    @valid_attrs %{
      name: "Test Product",
      description: "A test product",
      category: "cosmetics",
      product_type: :cosmetic
    }
    @update_attrs %{
      name: "Updated Product",
      description: "Updated description"
    }
    @invalid_attrs %{name: nil, product_type: nil}

    test "create_product/2 with valid data creates a product", %{company: company} do
      assert {:ok, %Product{} = product} = Products.create_product(company, @valid_attrs)
      assert product.name == "Test Product"
      assert product.description == "A test product"
      assert product.category == "cosmetics"
      assert product.product_type == :cosmetic
      assert product.company_id == company.id
    end

    test "create_product/2 with invalid data returns error changeset", %{company: company} do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(company, @invalid_attrs)
    end

    test "create_product/2 with launch window dates creates product with launch window", %{
      company: company
    } do
      today = Date.utc_today()
      start_date = Date.add(today, -7)
      end_date = Date.add(today, 7)

      attrs =
        Map.merge(@valid_attrs, %{
          launch_date: today,
          launch_window_start: start_date,
          launch_window_end: end_date
        })

      assert {:ok, %Product{} = product} = Products.create_product(company, attrs)
      assert product.launch_date == today
      assert product.launch_window_start == start_date
      assert product.launch_window_end == end_date
    end

    test "update_product/2 with valid data updates the product", %{company: company} do
      {:ok, product} = Products.create_product(company, @valid_attrs)
      assert {:ok, %Product{} = updated_product} = Products.update_product(product, @update_attrs)
      assert updated_product.name == "Updated Product"
      assert updated_product.description == "Updated description"
    end

    test "update_product/2 with invalid data returns error changeset", %{company: company} do
      {:ok, product} = Products.create_product(company, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "get_product/1 returns the product with given id", %{company: company} do
      {:ok, product} = Products.create_product(company, @valid_attrs)
      assert Products.get_product(product.id).id == product.id
    end

    test "get_product!/1 returns the product with given id", %{company: company} do
      {:ok, product} = Products.create_product(company, @valid_attrs)
      assert Products.get_product!(product.id).id == product.id
    end

    test "get_product!/1 raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product!(Ecto.UUID.generate())
      end
    end

    test "list_products/1 returns all products for a company", %{company: company} do
      {:ok, product1} = Products.create_product(company, @valid_attrs)

      {:ok, _product2} =
        Products.create_product(company, Map.merge(@valid_attrs, %{name: "Product 2"}))

      products = Products.list_products(company)
      assert length(products) == 2
      assert product1 in products
    end

    test "list_products_in_launch_window/1 returns products in launch window" do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Launch Company",
          domain: "launch.com",
          industry: "Tech",
          company_type: :product_based
        })

      today = Date.utc_today()
      start_date = Date.add(today, -7)
      end_date = Date.add(today, 7)

      {:ok, _in_window} =
        Products.create_product(
          company,
          Map.merge(@valid_attrs, %{
            name: "In Window",
            launch_date: today,
            launch_window_start: start_date,
            launch_window_end: end_date
          })
        )

      {:ok, _out_of_window} =
        Products.create_product(
          company,
          Map.merge(@valid_attrs, %{
            name: "Out of Window",
            launch_date: Date.add(today, -30),
            launch_window_start: Date.add(today, -40),
            launch_window_end: Date.add(today, -20)
          })
        )

      {:ok, _no_launch} =
        Products.create_product(company, Map.merge(@valid_attrs, %{name: "No Launch"}))

      products = Products.list_products_in_launch_window()
      assert length(products) == 1
      assert Enum.at(products, 0).name == "In Window"
    end
  end

  describe "competitor_products" do
    setup do
      {:ok, company} =
        Accounts.create_company(%{
          name: "Test Company",
          domain: "testcompany.com",
          industry: "Technology",
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

    test "add_competitor_product/2 creates a competitor product relationship", %{product: product} do
      competitor_attrs = %{
        name: "Competitor Product",
        description: "A competitor",
        category: "cosmetics",
        brand_name: "Competitor Brand"
      }

      assert {:ok, %CompetitorProduct{} = competitor} =
               Products.add_competitor_product(product, competitor_attrs)

      assert competitor.name == "Competitor Product"
      assert competitor.product_id == product.id
      assert competitor.brand_name == "Competitor Brand"
    end

    test "list_competitor_products/1 returns all competitors for a product", %{product: product} do
      {:ok, _competitor1} =
        Products.add_competitor_product(product, %{
          name: "Comp1",
          description: "Competitor 1",
          category: "cosmetics"
        })

      {:ok, _competitor2} =
        Products.add_competitor_product(product, %{
          name: "Comp2",
          description: "Competitor 2",
          category: "cosmetics"
        })

      competitors = Products.list_competitor_products(product)
      assert length(competitors) == 2
    end

    test "remove_competitor_product/2 removes the competitor relationship", %{product: product} do
      {:ok, competitor} =
        Products.add_competitor_product(product, %{
          name: "Competitor",
          description: "A competitor",
          category: "cosmetics"
        })

      assert {:ok, _} = Products.remove_competitor_product(product, competitor.id)

      competitors = Products.list_competitor_products(product)
      assert length(competitors) == 0
    end

    test "remove_competitor_product/2 returns error for invalid competitor_id", %{
      product: product
    } do
      assert {:error, :not_found} =
               Products.remove_competitor_product(product, Ecto.UUID.generate())
    end
  end
end

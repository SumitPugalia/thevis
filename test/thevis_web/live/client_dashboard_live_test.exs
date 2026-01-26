defmodule ThevisWeb.ClientDashboardLiveTest do
  @moduledoc """
  Tests for client dashboard LiveView.
  """

  use ThevisWeb.ConnCase

  import Phoenix.LiveViewTest
  import Thevis.Factory
  alias Thevis.Accounts

  describe "Dashboard access" do
    test "redirects to login when not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/dashboard")
      assert redirected_to(conn) == ~p"/login"
    end

    test "shows dashboard when authenticated", %{conn: conn} do
      # Create a user
      {:ok, _user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      # Sign in via login endpoint to properly set up session
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "client@example.com", "password" => "password1234"}
        })

      # Follow redirect to dashboard
      assert redirected_to(conn) == ~p"/dashboard"
      dashboard_conn = get(conn, ~p"/dashboard")

      # Should render the dashboard
      assert html_response(dashboard_conn, 200) =~ "Dashboard"
      assert html_response(dashboard_conn, 200) =~ "Welcome back"
    end

    test "displays empty state when user has no companies", %{conn: conn} do
      # Create a user
      {:ok, _user} =
        Accounts.create_user(%{
          email: "client@example.com",
          name: "Test Client",
          password: "password1234",
          role: :client
        })

      # Sign in via login endpoint to properly set up session
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => "client@example.com", "password" => "password1234"}
        })

      # Follow redirect
      assert redirected_to(conn) == ~p"/dashboard"

      # Now test LiveView
      {:ok, _index_live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Dashboard"
      assert html =~ "Welcome back"
      assert html =~ "No companies yet"
    end
  end

  describe "Dashboard with companies" do
    setup %{conn: conn} do
      user = insert(:user)
      company = insert(:company)
      insert(:role, user: user, company: company)
      product = insert(:product, company: company)
      project = insert(:product_project, product: product)

      # Authenticate
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => "password1234"}
        })

      assert redirected_to(conn) == ~p"/dashboard"
      dashboard_conn = get(conn, ~p"/dashboard")

      {:ok,
       conn: dashboard_conn, user: user, company: company, product: product, project: project}
    end

    test "displays company information", %{conn: conn, company: company} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ company.name
      assert html =~ company.domain
    end

    test "displays products for product-based company", %{conn: conn, product: product} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ product.name
      assert html =~ "Products"
    end

    test "displays projects", %{conn: conn, project: project} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ project.name
      assert html =~ "Projects"
    end

    test "displays quick stats", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ "Companies"
      assert html =~ "Products"
      assert html =~ "Services"
    end
  end

  describe "Dashboard with charts" do
    setup %{conn: conn} do
      user = insert(:user)
      company = insert(:company)
      insert(:role, user: user, company: company)
      product = insert(:product, company: company)
      project = insert(:product_project, product: product)

      # Create completed scan runs with entity snapshots for chart data
      scan_run1 =
        insert(:scan_run,
          project: project,
          status: :completed,
          scan_type: :entity_probe,
          completed_at: DateTime.add(DateTime.utc_now(), -7, :day)
        )

      scan_run2 =
        insert(:scan_run,
          project: project,
          status: :completed,
          scan_type: :entity_probe,
          completed_at: DateTime.add(DateTime.utc_now(), -3, :day)
        )

      insert(:entity_snapshot,
        scan_run: scan_run1,
        optimizable_type: :product,
        optimizable_id: product.id,
        confidence_score: 0.75,
        inserted_at: DateTime.add(DateTime.utc_now(), -7, :day)
      )

      insert(:entity_snapshot,
        scan_run: scan_run2,
        optimizable_type: :product,
        optimizable_id: product.id,
        confidence_score: 0.85,
        inserted_at: DateTime.add(DateTime.utc_now(), -3, :day)
      )

      # Authenticate
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => "password1234"}
        })

      assert redirected_to(conn) == ~p"/dashboard"
      dashboard_conn = get(conn, ~p"/dashboard")

      {:ok,
       conn: dashboard_conn,
       user: user,
       company: company,
       project: project,
       scan_runs: [scan_run1, scan_run2]}
    end

    test "displays charts section when confidence data exists", %{conn: conn, company: company} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ "Confidence Score Trends"
      assert html =~ company.name
      # Check for chart canvas element
      assert html =~ "confidence-chart"
      assert html =~ "phx-hook=\"ConfidenceChart\""
    end

    test "chart data is properly formatted", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      # Verify chart canvas has data attribute
      assert html =~ "data-chart-data"
    end
  end

  describe "Product form" do
    setup %{conn: conn} do
      user = insert(:user)
      company = insert(:company)
      insert(:role, user: user, company: company)

      # Authenticate
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => "password1234"}
        })

      assert redirected_to(conn) == ~p"/dashboard"
      dashboard_conn = get(conn, ~p"/dashboard")

      {:ok, conn: dashboard_conn, user: user, company: company}
    end

    test "shows add product form when button clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(view, "button[phx-click='show_add_product']")

      view
      |> element("button[phx-click='show_add_product']")
      |> render_click()

      assert has_element?(view, "#product-form")
      assert has_element?(view, "#product-modal")
    end

    test "can cancel product form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Open form
      view
      |> element("button[phx-click='show_add_product']")
      |> render_click()

      assert has_element?(view, "#product-form")

      # Cancel form
      view
      |> element("button[phx-click='cancel_add_product']")
      |> render_click()

      refute has_element?(view, "#product-form")
    end
  end

  describe "Service form" do
    setup %{conn: conn} do
      user = insert(:user)
      company = insert(:service_based_company)
      insert(:role, user: user, company: company)

      # Authenticate
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => "password1234"}
        })

      assert redirected_to(conn) == ~p"/dashboard"
      dashboard_conn = get(conn, ~p"/dashboard")

      {:ok, conn: dashboard_conn, user: user, company: company}
    end

    test "shows add service form when button clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(view, "button[phx-click='show_add_service']")

      view
      |> element("button[phx-click='show_add_service']")
      |> render_click()

      assert has_element?(view, "#service-form")
      assert has_element?(view, "#service-modal")
    end
  end
end

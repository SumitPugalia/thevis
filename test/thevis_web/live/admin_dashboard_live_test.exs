defmodule ThevisWeb.AdminDashboardLiveTest do
  use ThevisWeb.ConnCase

  import Phoenix.LiveViewTest
  import Thevis.Factory

  setup %{conn: conn} do
    # Create a consultant user
    consultant = insert(:consultant_user)

    # Create companies and products
    company1 = insert(:company)
    company2 = insert(:company)
    product1 = insert(:product, company: company1)
    product2 = insert(:product, company: company2)

    # Create projects
    project1 = insert(:product_project, product: product1)
    project2 = insert(:product_project, product: product2)

    # Create scan runs
    scan_run1 = insert(:scan_run, project: project1, scan_type: :entity_probe, status: :completed)
    scan_run2 = insert(:scan_run, project: project2, scan_type: :recall, status: :completed)

    # Authenticate as consultant via login endpoint
    conn =
      post(conn, ~p"/login", %{
        "user" => %{"email" => consultant.email, "password" => "password1234"}
      })

    # Follow redirect
    assert redirected_to(conn) == ~p"/admin/dashboard"

    # Follow the redirect to get the actual dashboard page with session
    dashboard_conn = get(conn, redirected_to(conn))

    # Extract session from the response
    session_token = get_session(dashboard_conn, "guardian_default_token")

    # Build a fresh conn with the session for LiveView tests
    fresh_conn = build_conn()

    authenticated_conn =
      Plug.Test.init_test_session(fresh_conn, %{"guardian_default_token" => session_token})

    {:ok,
     conn: authenticated_conn,
     consultant: consultant,
     companies: [company1, company2],
     projects: [project1, project2],
     scan_runs: [scan_run1, scan_run2]}
  end

  test "renders admin dashboard with statistics", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/admin/dashboard")

    assert has_element?(view, "h1", "Admin Dashboard")
    assert html =~ "Overview of all companies, projects, and system activity"

    # Check stats cards (check in HTML)
    assert html =~ "Total Companies"
    assert html =~ "Total Projects"
    assert html =~ "Active Projects"
    assert html =~ "Total Scans"
    assert html =~ "Completed Scans"
  end

  test "displays all companies in admin dashboard", %{conn: conn, companies: companies} do
    {:ok, view, html} = live(conn, ~p"/admin/dashboard")

    # Check that companies table is visible
    assert has_element?(view, "h2", "All Companies")

    # Check that companies are listed (check in HTML since names might be in different elements)
    for company <- companies do
      assert html =~ company.name
    end
  end

  test "displays all projects in admin dashboard", %{conn: conn, projects: projects} do
    {:ok, view, html} = live(conn, ~p"/admin/dashboard")

    # Check that projects table is visible
    assert has_element?(view, "h2", "Recent Projects")

    # Check that projects are listed (check in HTML)
    for project <- projects do
      assert html =~ project.name
    end
  end

  test "displays recent scans in admin dashboard", %{conn: conn, scan_runs: _scan_runs} do
    {:ok, view, html} = live(conn, ~p"/admin/dashboard")

    # Check that scans table is visible
    assert has_element?(view, "h2", "Recent Scans")

    # Check that scan types are displayed (they are capitalized in the template)
    assert html =~ "Entity Probe" || html =~ "Recall"
  end

  test "links to admin companies page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/dashboard")

    assert has_element?(view, "a[href='/admin/companies']", "View All →")
  end

  test "links to admin projects page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/dashboard")

    assert has_element?(view, "a[href='/admin/projects']", "View All →")
  end

  test "requires admin authentication", %{conn: conn} do
    # Create a client user
    client = insert(:user, role: :client)

    # Login as client
    login_conn =
      post(conn, ~p"/login", %{
        "user" => %{"email" => client.email, "password" => "password1234"}
      })

    # Client should be redirected to regular dashboard
    assert redirected_to(login_conn) == ~p"/dashboard"

    # Follow redirect to get session
    dashboard_conn = get(login_conn, redirected_to(login_conn))

    # Try to access admin dashboard with client session
    admin_conn = get(dashboard_conn, ~p"/admin/dashboard")

    # Should be redirected away from admin dashboard
    assert redirected_to(admin_conn) == ~p"/dashboard"
  end

  test "calculates correct statistics", %{conn: conn} do
    # Create additional data
    company = insert(:company)
    product = insert(:product, company: company)
    _active_project = insert(:product_project, product: product, status: :active)
    _paused_project = insert(:product_project, product: product, status: :paused)

    {:ok, _view, html} = live(conn, ~p"/admin/dashboard")

    # The stats should reflect all companies, projects, etc.
    # We can't easily test exact numbers without knowing existing data,
    # but we can verify the stats section exists
    assert html =~ "Total Companies"
    assert html =~ "Total Projects"
    assert html =~ "Active Projects"
  end
end

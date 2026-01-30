defmodule ThevisWeb.Router do
  use ThevisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ThevisWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Guardian.Plug.Pipeline,
      module: Thevis.Guardian,
      error_handler: ThevisWeb.Plugs.GuardianErrorHandler

    plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug ThevisWeb.Plugs.FetchCurrentUser
  end

  pipeline :require_authenticated_user do
    # Ensure resource is loaded before checking authentication
    plug Guardian.Plug.LoadResource, allow_blank: false

    plug Guardian.Plug.EnsureAuthenticated,
      error_handler: ThevisWeb.Plugs.GuardianErrorHandler,
      key: :default

    plug ThevisWeb.Plugs.RequireAuthenticatedUser
  end

  pipeline :require_admin do
    plug ThevisWeb.Plugs.RequireAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes (no authentication required)
  scope "/", ThevisWeb do
    pipe_through :browser

    # Landing page
    live "/", PageLive, :index

    # Public GEO pages (GEO Plan: About, GEO explainer, FAQ)
    live "/about", AboutLive, :index
    live "/geo", GeoLive, :index
    live "/faq", FaqLive, :index

    # Authentication routes
    live "/register", UserRegistrationLive, :new
    live "/login", UserLoginLive, :new
    post "/login", UserAuthController, :create
    delete "/logout", UserAuthController, :delete
  end

  # Protected client routes (authentication required)
  scope "/", ThevisWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/dashboard", ClientDashboardLive, :index
    live "/onboarding", ClientOnboardingLive, :index

    # Company management
    live "/companies", CompanyLive.Index, :index
    live "/companies/new", CompanyLive.Index, :new
    live "/companies/:id", CompanyLive.Show, :show
    live "/companies/:id/edit", CompanyLive.Index, :edit

    # Product management
    live "/products", ProductLive.Index, :index
    live "/products/new", ProductLive.Index, :new
    live "/products/:id", ProductLive.Show, :show
    live "/products/:id/edit", ProductLive.Index, :edit

    # Project management
    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id", ProjectLive.Show, :show
    live "/projects/:id/edit", ProjectLive.Index, :edit
    live "/projects/:id/scans", ScanLive.Index, :index
    live "/projects/:id/scans/:scan_run_id", ScanLive.Show, :show

    # Client report download (PRD 5.1.5 Exportable Audit Report)
    get "/projects/:project_id/report", ReportController, :download
    get "/projects/:project_id/report/:scan_run_id", ReportController, :download
  end

  # Admin routes (consultant/admin only)
  scope "/admin", ThevisWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live "/dashboard", AdminDashboardLive, :index

    # Company management (admin view)
    live "/companies", CompanyLive.Index, :index
    live "/companies/new", CompanyLive.Index, :new
    live "/companies/:id", CompanyLive.Show, :show
    live "/companies/:id/edit", CompanyLive.Index, :edit

    # Product management (admin view)
    live "/products", ProductLive.Index, :index
    live "/products/new", ProductLive.Index, :new
    live "/products/:id", ProductLive.Show, :show
    live "/products/:id/edit", ProductLive.Index, :edit

    # Project management (admin view)
    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id", ProjectLive.Show, :show
    live "/projects/:id/edit", ProjectLive.Index, :edit
    live "/projects/:id/scans", ScanLive.Index, :index
    live "/projects/:id/scans/:scan_run_id", ScanLive.Show, :show

    # Consultant Strategy Tools
    live "/tasks", Consultant.TaskBoardLive, :index
    live "/tasks/project/:project_id", Consultant.TaskBoardLive, :index

    # Consultant Wiki Management
    live "/wikis", Consultant.WikiManagementLive, :index
    live "/wikis/project/:project_id", Consultant.WikiManagementLive, :index

    # Consultant Campaign Management
    live "/campaigns", Consultant.CampaignManagementLive, :index
    live "/campaigns/project/:project_id", Consultant.CampaignManagementLive, :index

    # Consultant Platform Settings
    live "/platform-settings", Consultant.PlatformSettingsLive, :index
    live "/platform-settings/project/:project_id", Consultant.PlatformSettingsLive, :index

    # Report download (admin)
    get "/projects/:project_id/report", ReportController, :download
    get "/projects/:project_id/report/:scan_run_id", ReportController, :download
  end

  # Other scopes may use custom stacks.
  # scope "/api", ThevisWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:thevis, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ThevisWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

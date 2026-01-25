defmodule ThevisWeb.Router do
  use ThevisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ThevisWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ThevisWeb do
    pipe_through :browser

    live "/", CompanyLive.Index, :index
    live "/companies", CompanyLive.Index, :index
    live "/companies/new", CompanyLive.Index, :new
    live "/companies/:id", CompanyLive.Show, :show
    live "/companies/:id/edit", CompanyLive.Index, :edit

    live "/products", ProductLive.Index, :index
    live "/products/new", ProductLive.Index, :new
    live "/products/:id", ProductLive.Show, :show
    live "/products/:id/edit", ProductLive.Index, :edit

    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id", ProjectLive.Show, :show
    live "/projects/:id/edit", ProjectLive.Index, :edit
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

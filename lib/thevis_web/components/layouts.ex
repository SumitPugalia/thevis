defmodule ThevisWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ThevisWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Base URL for the application (used for OG tags and JSON-LD).
  Uses Endpoint config so dev is localhost and prod is thevis.ai.
  """
  def base_url do
    String.trim_trailing(ThevisWeb.Endpoint.url(), "/")
  end

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_user, :any, default: nil, doc: "the current authenticated user"
  attr :page_title, :string, default: nil, doc: "the page title"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :meta_description, :string,
    default: nil,
    doc: "meta description and og:description for GEO and search"

  attr :show_organization_schema, :boolean,
    default: false,
    doc: "when true, root layout injects JSON-LD Organization schema (homepage)"

  slot :inner_block, required: true

  def app(assigns) do
    assigns =
      assign(
        assigns,
        :is_landing_page,
        assigns.page_title == "thevis.ai - Making brands visible to AI"
      )

    ~H"""
    <div class="min-h-screen bg-gray-50">
      <!-- Navigation Header -->
      <nav class={[
        "sticky top-0 z-50",
        if(@is_landing_page,
          do: "bg-white/80 backdrop-blur-sm border-b border-gray-200",
          else: "bg-white border-b border-gray-200"
        )
      ]}>
        <div class="w-full px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between h-16">
            <div class="flex">
              <div class="flex-shrink-0 flex items-center">
                <.link navigate={~p"/"} class="flex items-center gap-2">
                  <img
                    src={~p"/images/thevis.png"}
                    alt="thevis.ai"
                    class="h-20"
                  />
                </.link>
              </div>
              <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
                <%= if @current_user do %>
                  <.link
                    navigate={~p"/companies"}
                    class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  >
                    Companies
                  </.link>
                  <.link
                    navigate={~p"/products"}
                    class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  >
                    Products
                  </.link>
                  <.link
                    navigate={~p"/projects"}
                    class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  >
                    Projects
                  </.link>
                  <%= if @current_user.role == :consultant do %>
                    <.link
                      navigate={~p"/admin/dashboard"}
                      class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                    >
                      Admin Dashboard
                    </.link>
                  <% else %>
                    <.link
                      navigate={~p"/dashboard"}
                      class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                    >
                      Dashboard
                    </.link>
                  <% end %>
                <% else %>
                  <.link
                    navigate={~p"/about"}
                    class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  >
                    About
                  </.link>
                  <.link
                    navigate={~p"/geo"}
                    class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  >
                    What is GEO?
                  </.link>
                  <.link
                    navigate={~p"/faq"}
                    class="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  >
                    FAQ
                  </.link>
                <% end %>
              </div>
            </div>
            <div class="flex items-center space-x-4">
              <%= if @current_user do %>
                <span class="text-sm text-gray-600">{@current_user.name}</span>
                <.link
                  href={~p"/logout"}
                  method="delete"
                  class="text-sm text-gray-600 hover:text-gray-900 font-medium"
                >
                  Logout
                </.link>
              <% end %>
            </div>
          </div>
        </div>
      </nav>
      
    <!-- Main Content -->
      <main class={if(@is_landing_page, do: "w-full", else: "w-full px-4 sm:px-6 lg:px-8 py-8")}>
        {render_slot(@inner_block)}
      </main>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Public footer for landing, About, GEO, and FAQ pages. Links to core GEO pages.
  """
  def public_footer(assigns) do
    ~H"""
    <footer class="bg-blue-50 border-t border-blue-100 py-12 mt-12">
      <div class="w-full px-4 sm:px-6 lg:px-8 max-w-4xl mx-auto">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div class="flex items-center gap-2">
            <span class="text-xl font-bold text-gray-900">thevis</span>
            <span class="text-sm text-gray-500">.ai</span>
          </div>
          <nav class="flex flex-wrap gap-6 text-sm">
            <.link navigate={~p"/"} class="text-gray-600 hover:text-gray-900">Home</.link>
            <.link navigate={~p"/about"} class="text-gray-600 hover:text-gray-900">About</.link>
            <.link navigate={~p"/geo"} class="text-gray-600 hover:text-gray-900">What is GEO?</.link>
            <.link navigate={~p"/faq"} class="text-gray-600 hover:text-gray-900">FAQ</.link>
          </nav>
        </div>
        <p class="mt-4 text-sm text-gray-600">© 2025 thevis.ai. All rights reserved.</p>
      </div>
    </footer>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end

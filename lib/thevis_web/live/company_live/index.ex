defmodule ThevisWeb.CompanyLive.Index do
  @moduledoc """
  LiveView for listing and managing companies.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Accounts.Company

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    socket = assign(socket, :current_user, current_user)
    {:ok, stream(socket, :companies, [])}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params, url)}
  end

  defp apply_action(socket, :index, _params, url) do
    current_user = socket.assigns[:current_user]
    is_admin_route = String.starts_with?(url, "/admin")

    companies =
      if is_admin_route || (current_user && current_user.role == :consultant) do
        # Admin route or consultant: show all companies
        Accounts.list_companies()
      else
        # Client route: show only user's companies
        Accounts.list_companies_for_user(current_user)
      end

    socket
    |> assign(:page_title, "Companies")
    |> assign(:company, nil)
    |> assign(:current_user, current_user)
    |> assign(:is_admin_route, is_admin_route)
    |> stream(:companies, companies, reset: true)
  end

  defp apply_action(socket, :new, _params, url) do
    is_admin_route = String.starts_with?(url, "/admin")

    socket
    |> assign(:page_title, "New Company")
    |> assign(:company, %Company{})
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:is_admin_route, is_admin_route)
  end

  defp apply_action(socket, :edit, %{"id" => id}, url) do
    is_admin_route = String.starts_with?(url, "/admin")

    socket
    |> assign(:page_title, "Edit Company")
    |> assign(:company, Accounts.get_company!(id))
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:is_admin_route, is_admin_route)
  end

  @impl true
  def handle_info({ThevisWeb.CompanyLive.FormComponent, {:saved, company}}, socket) do
    {:noreply, stream_insert(socket, :companies, company)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    company = Accounts.get_company!(id)
    {:ok, _} = Accounts.delete_company(company)

    {:noreply, stream_delete(socket, :companies, company)}
  end
end

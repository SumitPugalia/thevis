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
    {:ok, stream(socket, :companies, Accounts.list_companies())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Companies")
    |> assign(:company, nil)
    |> assign(:current_user, socket.assigns[:current_user])
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Company")
    |> assign(:company, %Company{})
    |> assign(:current_user, socket.assigns[:current_user])
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Company")
    |> assign(:company, Accounts.get_company!(id))
    |> assign(:current_user, socket.assigns[:current_user])
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

  defp company_type_badge(:product_based), do: "bg-blue-100 text-blue-800"
  defp company_type_badge(:service_based), do: "bg-purple-100 text-purple-800"
end

defmodule ThevisWeb.ProductLive.Index do
  @moduledoc """
  LiveView for listing and managing products.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Products
  alias Thevis.Products.Product

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    companies = Accounts.list_companies(company_type: :product_based)

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:companies, companies)
      |> stream(:products, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params, url)}
  end

  defp apply_action(socket, :index, _params, url) do
    current_user = socket.assigns[:current_user]
    is_admin_route = String.starts_with?(url, "/admin")

    products =
      if is_admin_route || (current_user && current_user.role == :consultant) do
        # Admin route or consultant: show all products
        load_all_products()
      else
        # Client route: show only user's products
        load_user_products(current_user)
      end

    socket
    |> assign(:page_title, "Products")
    |> assign(:product, nil)
    |> assign(:current_user, current_user)
    |> assign(:is_admin_route, is_admin_route)
    |> stream(:products, products, reset: true)
  end

  defp apply_action(socket, :new, _params, url) do
    is_admin_route = String.starts_with?(url, "/admin")
    current_user = socket.assigns[:current_user]

    companies =
      if is_admin_route || (current_user && current_user.role == :consultant) do
        Accounts.list_companies(company_type: :product_based)
      else
        user_companies = Accounts.list_companies_for_user(current_user)
        Enum.filter(user_companies, &(&1.company_type == :product_based))
      end

    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
    |> assign(:current_user, current_user)
    |> assign(:is_admin_route, is_admin_route)
    |> assign(:companies, companies)
  end

  defp apply_action(socket, :edit, %{"id" => id}, url) do
    is_admin_route = String.starts_with?(url, "/admin")

    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Products.get_product!(id))
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:is_admin_route, is_admin_route)
  end

  defp load_all_products do
    companies = Accounts.list_companies(company_type: :product_based)

    Enum.flat_map(companies, fn company ->
      Products.list_products(company)
    end)
  end

  defp load_user_products(user) do
    user_companies = Accounts.list_companies_for_user(user)
    product_based_companies = Enum.filter(user_companies, &(&1.company_type == :product_based))

    Enum.flat_map(product_based_companies, fn company ->
      Products.list_products(company)
    end)
  end

  @impl true
  def handle_info({ThevisWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Products.get_product!(id)
    {:ok, _} = Products.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end

  defp product_type_badge(:cosmetic), do: "bg-pink-100 text-pink-800"
  defp product_type_badge(:edible), do: "bg-green-100 text-green-800"
  defp product_type_badge(:sweet), do: "bg-yellow-100 text-yellow-800"
  defp product_type_badge(:d2c), do: "bg-blue-100 text-blue-800"
  defp product_type_badge(:fashion), do: "bg-purple-100 text-purple-800"
  defp product_type_badge(:wellness), do: "bg-indigo-100 text-indigo-800"
  defp product_type_badge(_), do: "bg-gray-100 text-gray-800"
end

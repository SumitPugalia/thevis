defmodule ThevisWeb.ProductLive.Show do
  @moduledoc """
  LiveView for showing a single product.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    product = Products.get_product!(id)
    company = Accounts.get_company!(product.company_id)

    {:noreply,
     socket
     |> assign(:page_title, product.name)
     |> assign(:product, product)
     |> assign(:company, company)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">{@product.name}</h1>
            <p class="mt-2 text-sm text-gray-600">{@company.name}</p>
          </div>
          <.link
            navigate={~p"/admin/products/#{@product.id}/edit"}
            class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors"
          >
            <.icon name="hero-pencil" class="w-5 h-5" /> Edit
          </.link>
        </div>

        <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-6">
          <dl class="grid grid-cols-1 gap-6 sm:grid-cols-2">
            <div>
              <dt class="text-sm font-medium text-gray-500">Category</dt>
              <dd class="mt-1 text-sm text-gray-900">{@product.category || "-"}</dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Product Type</dt>
              <dd class="mt-1">
                <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{product_type_badge(@product.product_type)}"}>
                  {String.capitalize(to_string(@product.product_type))}
                </span>
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Description</dt>
              <dd class="mt-1 text-sm text-gray-900">{@product.description || "-"}</dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-gray-500">Launch Window</dt>
              <dd class="mt-1 text-sm text-gray-900">
                <%= if @product.launch_window_start && @product.launch_window_end do %>
                  {Calendar.strftime(@product.launch_window_start, "%b %d, %Y")} - {Calendar.strftime(
                    @product.launch_window_end,
                    "%b %d, %Y"
                  )}
                <% else %>
                  <span class="text-gray-400">No launch window</span>
                <% end %>
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp product_type_badge(:cosmetic), do: "bg-pink-100 text-pink-800"
  defp product_type_badge(:edible), do: "bg-green-100 text-green-800"
  defp product_type_badge(:sweet), do: "bg-yellow-100 text-yellow-800"
  defp product_type_badge(:d2c), do: "bg-blue-100 text-blue-800"
  defp product_type_badge(:fashion), do: "bg-purple-100 text-purple-800"
  defp product_type_badge(:wellness), do: "bg-indigo-100 text-indigo-800"
  defp product_type_badge(_), do: "bg-gray-100 text-gray-800"
end

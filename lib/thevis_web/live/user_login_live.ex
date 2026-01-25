defmodule ThevisWeb.UserLoginLive do
  @moduledoc """
  LiveView for client login.
  """

  use ThevisWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-md">
        <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-8">
          <div class="text-center mb-8">
            <h1 class="text-3xl font-bold text-gray-900">Sign In</h1>
            <p class="mt-2 text-sm text-gray-600">Welcome back to thevis.ai</p>
          </div>

          <.form for={@form} id="login-form" action={~p"/login"} phx-update="ignore" class="space-y-6">
            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              required
              placeholder="you@example.com"
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              required
            />
            <div>
              <.button
                phx-disable-with="Signing in..."
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors"
              >
                Sign in <span aria-hidden="true">→</span>
              </.button>
            </div>
          </.form>

          <div class="mt-6 text-center">
            <p class="text-sm text-gray-600">
              Don't have an account?
              <.link navigate={~p"/register"} class="text-blue-600 hover:text-blue-900 font-medium">
                Sign up
              </.link>
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end

defmodule ThevisWeb.UserRegistrationLive do
  @moduledoc """
  LiveView for client registration/signup.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Accounts.User

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-md">
        <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-8">
          <div class="text-center mb-8">
            <h1 class="text-3xl font-bold text-gray-900">Create Account</h1>
            <p class="mt-2 text-sm text-gray-600">Sign up to get started with thevis.ai</p>
          </div>

          <.form
            for={@form}
            id="registration-form"
            phx-submit="save"
            phx-change="validate"
            class="space-y-6"
          >
            <.input
              field={@form[:name]}
              type="text"
              label="Full Name"
              required
              placeholder="John Doe"
            />
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
              placeholder="Minimum 12 characters"
            />

            <div class="flex items-center">
              <input
                id="terms"
                name="terms"
                type="checkbox"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                required
              />
              <label for="terms" class="ml-2 block text-sm text-gray-600">
                I agree to the
                <a href="#" class="text-blue-600 hover:text-blue-900">Terms of Service</a>
                and <a href="#" class="text-blue-600 hover:text-blue-900">Privacy Policy</a>
              </label>
            </div>

            <div>
              <.button
                phx-disable-with="Creating account..."
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors"
              >
                Create Account
              </.button>
            </div>
          </.form>

          <div class="mt-6 text-center">
            <p class="text-sm text-gray-600">
              Already have an account?
              <.link navigate={~p"/login"} class="text-blue-600 hover:text-blue-900 font-medium">
                Sign in
              </.link>
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(:form, to_form(changeset))

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user_registration(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "role", "client")

    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully! Please sign in.")
         |> push_navigate(to: ~p"/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end

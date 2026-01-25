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

            <label class="flex items-start gap-3 cursor-pointer">
              <input
                id="terms"
                name="terms"
                type="checkbox"
                value="true"
                checked={@terms_accepted}
                phx-click="toggle_terms"
                phx-debounce="0"
                class="mt-0.5 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded cursor-pointer"
                required
              />
              <span class="text-sm text-gray-600">
                I agree to the
                <a
                  href="#"
                  class="text-blue-600 hover:text-blue-900 underline"
                  onclick="event.stopPropagation(); return false;"
                >
                  Terms of Service
                </a>
                and
                <a
                  href="#"
                  class="text-blue-600 hover:text-blue-900 underline"
                  onclick="event.stopPropagation(); return false;"
                >
                  Privacy Policy
                </a>
              </span>
            </label>

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
      |> assign(:terms_accepted, false)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("validate", params, socket) do
    IO.inspect(params, label: "VALIDATE EVENT - Full params")

    terms_accepted = params["terms"] == "true" || params["terms"] == true
    IO.inspect(terms_accepted, label: "Terms accepted status")

    user_params = Map.get(params, "user", %{})

    changeset =
      %User{}
      |> Accounts.change_user_registration(user_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:terms_accepted, terms_accepted)}
  end

  def handle_event("toggle_terms", %{"terms" => terms_value}, socket) do
    terms_accepted = terms_value == "true" || terms_value == true
    IO.inspect(terms_accepted, label: "TOGGLE TERMS - New value")

    {:noreply, assign(socket, :terms_accepted, terms_accepted)}
  end

  def handle_event("toggle_terms", _params, socket) do
    # Toggle if no value provided
    new_value = !socket.assigns[:terms_accepted]
    IO.inspect(new_value, label: "TOGGLE TERMS - Toggled to")

    {:noreply, assign(socket, :terms_accepted, new_value)}
  end

  def handle_event("save", params, socket) do
    IO.inspect(params, label: "SIGNUP EVENT - Full params")

    user_params = Map.get(params, "user", %{})
    terms_value = Map.get(params, "terms")
    IO.inspect(terms_value, label: "SIGNUP EVENT - Terms value")
    IO.inspect(user_params["email"], label: "SIGNUP EVENT - Email")

    unless terms_value == "true" || terms_value == true do
      IO.inspect("SIGNUP FAILED - Terms not accepted", label: "AUTH")

      {:noreply,
       socket
       |> put_flash(:error, "Please accept the Terms of Service and Privacy Policy to continue.")
       |> assign(:terms_accepted, false)}
    else
      user_params = Map.put(user_params, "role", "client")

      case Accounts.create_user(user_params) do
        {:ok, user} ->
          IO.inspect(user.id, label: "SIGNUP SUCCESS - User ID")
          IO.inspect(user.email, label: "SIGNUP SUCCESS - Email")

          {:noreply,
           socket
           |> put_flash(:info, "Account created successfully! Please sign in.")
           |> push_navigate(to: ~p"/login")}

        {:error, %Ecto.Changeset{} = changeset} ->
          IO.inspect(changeset.errors, label: "SIGNUP FAILED - Validation errors")
          {:noreply, assign(socket, :form, to_form(changeset))}
      end
    end
  end
end

defmodule ThevisWeb.CompanyLive.Index do
  @moduledoc """
  LiveView for listing and managing companies.
  """

  use ThevisWeb, :live_view

  alias Thevis.Accounts
  alias Thevis.Accounts.Company
  alias Thevis.Accounts.EntityBlockSuggestions

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    socket = assign(socket, :current_user, current_user)
    {:ok, stream(socket, :companies, [])}
  end

  @impl true
  def handle_params(params, url, socket) do
    live_action = socket.assigns.live_action
    socket = apply_action(socket, live_action, params, url)
    {:noreply, assign(socket, :live_action, live_action)}
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
    changeset = Company.changeset(%Company{}, %{})
    form = to_form(changeset, as: "company")

    socket
    |> assign(:page_title, "New Company")
    |> assign(:company, %Company{})
    |> assign(:form, form)
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:is_admin_route, is_admin_route)
    |> assign(:suggesting_entity_block, false)
  end

  defp apply_action(socket, :edit, %{"id" => id}, url) do
    is_admin_route = String.starts_with?(url, "/admin")
    company = Accounts.get_company!(id)
    changeset = Company.changeset(company, %{})
    form = to_form(changeset, as: "company")

    socket
    |> assign(:page_title, "Edit Company")
    |> assign(:company, company)
    |> assign(:form, form)
    |> assign(:current_user, socket.assigns[:current_user])
    |> assign(:is_admin_route, is_admin_route)
    |> assign(:suggesting_entity_block, false)
  end

  @impl true
  def handle_event("suggest_entity_block", _params, socket) do
    if not socket.assigns.is_admin_route do
      {:noreply, socket}
    else
      company = socket.assigns.company
      form = socket.assigns.form

      socket =
        assign(socket, :suggesting_entity_block, true)

      case suggest_and_merge(form, company) do
        {:ok, new_form} ->
          {:noreply,
           socket
           |> assign(:form, new_form)
           |> assign(:suggesting_entity_block, false)
           |> put_flash(:info, "Entity block suggested. Review and edit if needed, then Save.")}

        {:error, _reason} ->
          {:noreply,
           socket
           |> assign(:suggesting_entity_block, false)
           |> put_flash(:error, "Could not get suggestions. Check AI config and try again.")}
      end
    end
  end

  @impl true
  def handle_event("validate", %{"company" => company_params}, socket) do
    company = socket.assigns.company || %Company{}

    changeset =
      company
      |> Company.changeset(company_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: "company"))}
  end

  @impl true
  def handle_event("save", %{"company" => company_params}, socket) do
    company = socket.assigns.company
    current_user = socket.assigns.current_user
    is_admin_route = socket.assigns.is_admin_route

    result =
      if company.id do
        Accounts.update_company(company, company_params)
      else
        case Accounts.create_company(company_params) do
          {:ok, created} ->
            if current_user && current_user.role == :client do
              Accounts.assign_role(current_user, created, :owner)
            end

            {:ok, created}

          other ->
            other
        end
      end

    case result do
      {:ok, _saved_company} ->
        base = if is_admin_route, do: ~p"/admin/companies", else: ~p"/companies"

        {:noreply,
         socket
         |> put_flash(:info, "Company saved successfully.")
         |> push_navigate(to: base)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "company"))}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    base = if socket.assigns.is_admin_route, do: ~p"/admin/companies", else: ~p"/companies"
    {:noreply, push_navigate(socket, to: base)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    company = Accounts.get_company!(id)
    {:ok, _} = Accounts.delete_company(company)

    {:noreply, stream_delete(socket, :companies, company)}
  end

  @impl true
  def handle_info({ThevisWeb.CompanyLive.FormComponent, {:saved, company}}, socket) do
    {:noreply, stream_insert(socket, :companies, company)}
  end

  defp suggest_and_merge(_form, %Company{id: nil}), do: {:error, :new_company}

  defp suggest_and_merge(form, company) do
    case EntityBlockSuggestions.suggest_for_company(company) do
      {:ok, suggested} ->
        current_params = form.params
        merged = Map.merge(current_params, suggested)
        changeset = Company.changeset(company, merged)
        {:ok, to_form(changeset, as: "company")}

      {:error, _} ->
        {:error, :ai_error}
    end
  end
end

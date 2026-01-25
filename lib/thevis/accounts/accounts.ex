defmodule Thevis.Accounts do
  @moduledoc """
  The Accounts context for user and company management.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Accounts.{User, Company, Role}

  ## Users

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

      iex> list_users(role: :client)
      [%User{}, ...]

  """
  def list_users(opts \\ []) do
    User
    |> maybe_filter_by_role(opts[:role])
    |> Repo.all()
  end

  defp maybe_filter_by_role(query, nil), do: query
  defp maybe_filter_by_role(query, role), do: where(query, [u], u.role == ^role)

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  ## Companies

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

      iex> list_companies(company_type: :product_based)
      [%Company{}, ...]

  """
  def list_companies(opts \\ []) do
    Company
    |> maybe_filter_by_company_type(opts[:company_type])
    |> Repo.all()
  end

  defp maybe_filter_by_company_type(query, nil), do: query

  defp maybe_filter_by_company_type(query, company_type),
    do: where(query, [c], c.company_type == ^company_type)

  @doc """
  Gets a single company.

  Returns `nil` if the Company does not exist.

  ## Examples

      iex> get_company(123)
      %Company{}

      iex> get_company(456)
      nil

  """
  def get_company(id), do: Repo.get(Company, id)

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id), do: Repo.get!(Company, id)

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  ## Competitors

  @doc """
  Adds a competitor to a company's competitors array.

  ## Examples

      iex> add_competitor(company, %{name: "Competitor", domain: "competitor.com"})
      {:ok, %Company{}}

      iex> add_competitor(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def add_competitor(%Company{} = company, competitor_attrs) do
    competitors = company.competitors || []

    new_competitor =
      %{
        "name" => competitor_attrs[:name] || competitor_attrs["name"],
        "domain" => competitor_attrs[:domain] || competitor_attrs["domain"],
        "industry" => competitor_attrs[:industry] || competitor_attrs["industry"],
        "notes" => competitor_attrs[:notes] || competitor_attrs["notes"]
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    updated_competitors = competitors ++ [new_competitor]

    company
    |> Company.changeset(%{competitors: updated_competitors})
    |> Repo.update()
  end

  @doc """
  Removes a competitor from a company's competitors array by index.

  ## Examples

      iex> remove_competitor(company, 0)
      {:ok, %Company{}}

      iex> remove_competitor(company, 999)
      {:error, :not_found}

  """
  def remove_competitor(%Company{} = company, index) when is_integer(index) do
    competitors = company.competitors || []

    if index >= 0 && index < length(competitors) do
      updated_competitors = List.delete_at(competitors, index)

      company
      |> Company.changeset(%{competitors: updated_competitors})
      |> Repo.update()
    else
      {:error, :not_found}
    end
  end

  @doc """
  Updates a competitor in a company's competitors array by index.

  ## Examples

      iex> update_competitor(company, 0, %{name: "Updated Competitor"})
      {:ok, %Company{}}

      iex> update_competitor(company, 999, %{name: "Updated"})
      {:error, :not_found}

  """
  def update_competitor(%Company{} = company, index, competitor_attrs) when is_integer(index) do
    competitors = company.competitors || []

    if index >= 0 && index < length(competitors) do
      competitor = Enum.at(competitors, index)
      updated_competitor = Map.merge(competitor, competitor_attrs)
      updated_competitors = List.replace_at(competitors, index, updated_competitor)

      company
      |> Company.changeset(%{competitors: updated_competitors})
      |> Repo.update()
    else
      {:error, :not_found}
    end
  end

  @doc """
  Lists all competitors for a given company.

  ## Examples

      iex> list_competitors(company)
      [%{"name" => "Competitor", "domain" => "competitor.com"}, ...]

  """
  def list_competitors(%Company{} = company) do
    company.competitors || []
  end

  ## Roles

  @doc """
  Assigns a role to a user for a company.

  ## Examples

      iex> assign_role(user, company, :client)
      {:ok, %Role{}}

      iex> assign_role(user, company, :consultant)
      {:ok, %Role{}}

  """
  def assign_role(%User{} = user, %Company{} = company, role_type)
      when role_type in [:client, :consultant] do
    %Role{}
    |> Role.changeset(%{user_id: user.id, company_id: company.id, role_type: role_type})
    |> Repo.insert()
  end
end

defmodule Thevis.Projects do
  @moduledoc """
  The Projects context for project management.
  Projects optimize products.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Accounts.Company
  alias Thevis.Products.Product
  alias Thevis.Projects.Project

  ## Projects

  @doc """
  Returns the list of projects for a product.

  ## Examples

      iex> list_projects_for_product(product)
      [%Project{}, ...]

  """
  def list_projects_for_product(%Product{} = product) do
    Project
    |> where([p], p.product_id == ^product.id)
    |> preload(:product)
    |> Repo.all()
  end

  @doc """
  Returns all projects for a company (all products and their projects).

  ## Examples

      iex> list_projects_by_company(company)
      [%Project{}, ...]

  """
  def list_projects_by_company(%Company{} = company) do
    # Get all products for this company, then get their projects
    products = Thevis.Products.list_products(company)
    product_ids = Enum.map(products, & &1.id)

    Project
    |> where([p], p.product_id in ^product_ids)
    |> preload(:product)
    |> Repo.all()
  end

  @doc """
  Returns all projects across all companies (admin view).

  ## Examples

      iex> list_all_projects()
      [%Project{}, ...]

  """
  def list_all_projects do
    Project
    |> preload(:product)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Returns `nil` if the Project does not exist.

  ## Examples

      iex> get_project(123)
      %Project{}

      iex> get_project(456)
      nil

  """
  def get_project(id) do
    Project
    |> preload(:product)
    |> Repo.get(id)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id) do
    Project
    |> preload(:product)
    |> Repo.get!(id)
  end

  @doc """
  Creates a project for a product.

  ## Examples

      iex> create_project_for_product(product, %{field: value})
      {:ok, %Project{}}

      iex> create_project_for_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_for_product(%Product{} = product, attrs \\ %{}) do
    # Ensure all keys are strings to avoid mixed key errors
    attrs_string_keys =
      attrs
      |> Enum.map(fn {k, v} -> {to_string(k), v} end)
      |> Enum.into(%{})

    attrs_with_product = Map.put(attrs_string_keys, "product_id", product.id)

    %Project{}
    |> Project.changeset(attrs_with_product)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Gets the product for a project.

  ## Examples

      iex> get_product_for_project(project)
      %Product{}

  """
  def get_product_for_project(%Project{} = project) do
    Thevis.Repo.preload(project, :product).product
  end

  @doc """
  Checks if a user has access to a project.

  Consultants have access to all projects.
  Clients have access only to projects for their companies.

  ## Examples

      iex> user_has_access?(project, user)
      true

  """
  def user_has_access?(%Project{} = _project, %{role: :consultant}), do: true

  def user_has_access?(%Project{} = project, user) do
    # Preload product and company to check access
    project_with_associations =
      project
      |> Repo.preload(product: :company)

    if project_with_associations.product do
      company = project_with_associations.product.company
      user_companies = Thevis.Accounts.list_companies_for_user(user)
      Enum.any?(user_companies, &(&1.id == company.id))
    else
      false
    end
  end

  def user_has_access?(_project, _user), do: false
end

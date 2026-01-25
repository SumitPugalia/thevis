defmodule Thevis.Projects do
  @moduledoc """
  The Projects context for project management.
  Projects are polymorphic - they can optimize products or services.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Projects.Project
  alias Thevis.Products.Product
  alias Thevis.Accounts.Company

  ## Projects

  @doc """
  Returns the list of projects for a product.

  ## Examples

      iex> list_projects_for_product(product)
      [%Project{}, ...]

  """
  def list_projects_for_product(%Product{} = product) do
    Project
    |> where([p], p.optimizable_type == :product and p.optimizable_id == ^product.id)
    |> Repo.all()
  end

  @doc """
  Returns the list of projects for a service (company).

  ## Examples

      iex> list_projects_for_service(company)
      [%Project{}, ...]

  """
  def list_projects_for_service(%Company{} = company) do
    Project
    |> where([p], p.optimizable_type == :service and p.optimizable_id == ^company.id)
    |> Repo.all()
  end

  @doc """
  Returns all projects for a company (both product and service projects).

  ## Examples

      iex> list_projects_by_company(company)
      [%Project{}, ...]

  """
  def list_projects_by_company(%Company{} = company) do
    # For product-based companies, get all products and their projects
    # For service-based companies, get service projects directly
    if company.company_type == :product_based do
      # Get all products for this company, then get their projects
      products = Thevis.Products.list_products(company)
      product_ids = Enum.map(products, & &1.id)

      Project
      |> where([p], p.optimizable_type == :product and p.optimizable_id in ^product_ids)
      |> Repo.all()
    else
      # Service-based company - get service projects directly
      list_projects_for_service(company)
    end
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
  def get_project(id), do: Repo.get(Project, id)

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project for a product.

  ## Examples

      iex> create_project_for_product(product, %{field: value})
      {:ok, %Project{}}

      iex> create_project_for_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_for_product(%Product{} = product, attrs \\ %{}) do
    %Project{}
    |> Project.changeset(
      Map.merge(attrs, %{
        optimizable_type: :product,
        optimizable_id: product.id
      })
    )
    |> Repo.insert()
  end

  @doc """
  Creates a project for a service (company).

  ## Examples

      iex> create_project_for_service(company, %{field: value})
      {:ok, %Project{}}

      iex> create_project_for_service(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_for_service(%Company{} = company, attrs \\ %{}) do
    %Project{}
    |> Project.changeset(
      Map.merge(attrs, %{
        optimizable_type: :service,
        optimizable_id: company.id
      })
    )
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
end

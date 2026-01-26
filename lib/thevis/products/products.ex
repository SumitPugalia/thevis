defmodule Thevis.Products do
  @moduledoc """
  The Products context for product management.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Accounts.Company
  alias Thevis.Products.CompetitorProduct
  alias Thevis.Products.Product

  ## Products

  @doc """
  Returns the list of products for a company.

  ## Examples

      iex> list_products(company)
      [%Product{}, ...]

  """
  def list_products(%Company{} = company) do
    Product
    |> where([p], p.company_id == ^company.id)
    |> Repo.all()
  end

  @doc """
  Returns the list of products currently in launch window.

  ## Examples

      iex> list_products_in_launch_window()
      [%Product{}, ...]

  """
  def list_products_in_launch_window do
    today = Date.utc_today()

    Product
    |> where([p], not is_nil(p.launch_window_start) and not is_nil(p.launch_window_end))
    |> where([p], p.launch_window_start <= ^today)
    |> where([p], p.launch_window_end >= ^today)
    |> Repo.all()
  end

  @doc """
  Gets a single product.

  Returns `nil` if the Product does not exist.

  ## Examples

      iex> get_product(123)
      %Product{}

      iex> get_product(456)
      nil

  """
  def get_product(id), do: Repo.get(Product, id)

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(company, %{field: value})
      {:ok, %Product{}}

      iex> create_product(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(%Company{} = company, attrs \\ %{}) do
    # Normalize keys to strings to avoid mixed key errors
    # Ecto.Changeset.cast handles both atom and string keys, but mixing them causes errors
    normalized_attrs =
      attrs
      |> Enum.map(fn
        {k, v} when is_atom(k) -> {Atom.to_string(k), v}
        {k, v} -> {k, v}
      end)
      |> Map.new()

    attrs_with_company = Map.put(normalized_attrs, "company_id", company.id)

    %Product{}
    |> Product.changeset(attrs_with_company)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  ## Competitor Products

  @doc """
  Adds a competitor product for a given product.

  ## Examples

      iex> add_competitor_product(product, %{name: "Competitor", description: "A competitor"})
      {:ok, %CompetitorProduct{}}

      iex> add_competitor_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def add_competitor_product(%Product{} = product, attrs) do
    %CompetitorProduct{}
    |> CompetitorProduct.changeset(Map.put(attrs, :product_id, product.id))
    |> Repo.insert()
  end

  @doc """
  Removes a competitor product.

  ## Examples

      iex> remove_competitor_product(product, competitor_id)
      {:ok, %CompetitorProduct{}}

      iex> remove_competitor_product(product, invalid_id)
      {:error, :not_found}

  """
  def remove_competitor_product(%Product{} = product, competitor_id) do
    competitor =
      CompetitorProduct
      |> where([c], c.id == ^competitor_id and c.product_id == ^product.id)
      |> Repo.one()

    if competitor do
      Repo.delete(competitor)
    else
      {:error, :not_found}
    end
  end

  @doc """
  Lists all competitor products for a given product.

  ## Examples

      iex> list_competitor_products(product)
      [%CompetitorProduct{}, ...]

  """
  def list_competitor_products(%Product{} = product) do
    CompetitorProduct
    |> where([c], c.product_id == ^product.id)
    |> Repo.all()
  end
end

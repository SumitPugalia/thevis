defmodule Thevis.Services do
  @moduledoc """
  The Services context for service management.
  """

  import Ecto.Query, warn: false
  alias Thevis.Repo

  alias Thevis.Accounts.Company
  alias Thevis.Services.Service

  ## Services

  @doc """
  Returns the list of services for a company.

  ## Examples

      iex> list_services(company)
      [%Service{}, ...]

  """
  def list_services(%Company{} = company) do
    Service
    |> where([s], s.company_id == ^company.id)
    |> Repo.all()
  end

  @doc """
  Gets a single service.

  Returns `nil` if the Service does not exist.

  ## Examples

      iex> get_service(123)
      %Service{}

      iex> get_service(456)
      nil

  """
  def get_service(id), do: Repo.get(Service, id)

  @doc """
  Gets a single service.

  Raises `Ecto.NoResultsError` if the Service does not exist.

  ## Examples

      iex> get_service!(123)
      %Service{}

      iex> get_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service!(id), do: Repo.get!(Service, id)

  @doc """
  Creates a service.

  ## Examples

      iex> create_service(company, %{field: value})
      {:ok, %Service{}}

      iex> create_service(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service(%Company{} = company, attrs \\ %{}) do
    attrs_with_company = Map.merge(attrs, %{"company_id" => company.id})

    %Service{}
    |> Service.changeset(attrs_with_company)
    |> Repo.insert()
  end

  @doc """
  Updates a service.

  ## Examples

      iex> update_service(service, %{field: new_value})
      {:ok, %Service{}}

      iex> update_service(service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service(%Service{} = service, attrs) do
    service
    |> Service.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a service.

  ## Examples

      iex> delete_service(service)
      {:ok, %Service{}}

      iex> delete_service(service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service(%Service{} = service) do
    Repo.delete(service)
  end
end

defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo
  alias Siwapp.Schema.Invoices
  alias Siwapp.Schema.Customers

  @doc """
  Gets a list of invoices by updated date
  """
  def list() do
    # query = Query.invoices()
    Repo.all(Invoices)
  end

  @doc """
  Gets a list on the invoices that macht with the paramas
  """
  def list_by(_key, _value) do
    # query = Query.invoices_by(key, value)
    Repo.all(Invoices)
  end

  @doc """
  Creates an invoice
  """
  def create(attrs \\ %{}) do
    %Invoices{}
    |> Invoices.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an invoice
  """
  def update(%Invoices{} = invoice, attrs) do
    invoice
    |> Invoices.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an invoice
  """
  def delete(%Invoices{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Gets an invoice by id
  """
  def get!(id), do: Repo.get!(Invoices, id)

  @doc """
  Get a single invoice by the params
  """
  def get_by!(key, value) do
    Repo.get_by!(Invoices, %{key => value})
  end

  @doc """
  Create a new customer
  """
  def create_customer(attrs \\ %{}) do
    %Customers{}
    |> Customers.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update a customer
  """
  def update_customer(%Customers{} = customer, attrs) do
    customer
    |> Customers.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a customer
  """
  def delete_customer(%Customers{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Gets a customer by id
  """
  def get_customer!(id), do: Repo.get!(Customers, id)
end

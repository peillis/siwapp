defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo
  alias Siwapp.Schema.{Invoice, Customer}

  @doc """
  Gets a list of invoices by updated date
  """
  def list() do
    # query = Query.invoices()
    Repo.all(Invoice)
  end

  @doc """
  Gets a list on the invoices that macht with the paramas
  """
  def list_by(_key, _value) do
    # query = Query.invoices_by(key, value)
    Repo.all(Invoice)
  end

  @doc """
  Creates an invoice
  """
  def create(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an invoice
  """
  def update(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an invoice
  """
  def delete(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Gets an invoice by id
  """
  def get!(id), do: Repo.get!(Invoice, id)

  @doc """
  Get a single invoice by the params
  """
  def get_by!(key, value) do
    Repo.get_by!(Invoice, %{key => value})
  end

  @doc """
  Create a new customer
  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  def create_customer_void(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset_void(attrs)
  end

  @doc """
  Update a customer
  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a customer
  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Gets a customer by id
  """
  def get_customer!(id), do: Repo.get!(Customer, id)
end

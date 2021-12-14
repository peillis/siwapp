defmodule Siwapp.InvoicesContext do
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
  def list_invoices() do
    # query = Query.invoices()
    Repo.all(Invoices)
  end

  @doc """
  Gets a list on the invoices that macht with the paramas
  """
  def list_invoices_by(_key, _value) do
    # query = Query.invoices_by(key, value)
    Repo.all(Invoices)
  end

  @doc """
  Creates an invoice
  """
  def create_invoice(attrs \\ %{}) do
    %Invoices{}
    |> Invoices.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an invoice
  """
  def update_invoice(%Invoices{} = invoice, attrs) do
    invoice
    |> Invoices.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an invoice
  """
  def delete_invoice(%Invoices{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Gets an invoice by id
  """
  def get_invoice!(id), do: Repo.get!(Invoices, id)

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

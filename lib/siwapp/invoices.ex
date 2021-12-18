defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.Repo
  alias Siwapp.Invoices.Invoice

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
end

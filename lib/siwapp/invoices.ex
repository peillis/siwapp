defmodule Siwapp.Invoice do
  @moduledoc """
  The Invoice context.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo
  alias Siwapp.Schema.Invoice

  @doc """
  Gets a list of invoices by updated date
  """
  def list_invoices() do
    # query = Query.invoices()
    Repo.all(Invoice)
  end

  @doc """
  Gets a list on the invoices that macht with the paramas
  """
  def list_invoices_by(_key, _value) do
    # query = Query.invoices_by(key, value)
    Repo.all(Invoice)
  end

  @doc """
  Creates an invoice
  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an invoice
  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an invoice
  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end
  @doc """
  Gets an invoice by id
  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)
end

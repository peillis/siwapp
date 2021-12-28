defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.Repo
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Invoices.Query

  @doc """
  Gets a list of invoices by updated date
  """
  def list() do
    # query = Query.invoices()
    Repo.all(Invoice)
  end

  def list(:preload) do
    Repo.all(Query.list_preload())
  end

  @doc """
  Gets a list on the invoices that macht with the paramas
  """

  def list_by(key, value) do
    query =
      case {key, value} do
        {:with_terms, value} ->
          Query.with_terms(value)

        {:customer_id, value} ->
          Query.by(:customer_id, value)

        {:issue_date_gteq, value} ->
          Query.issue_date_gteq(value)

        {:issue_date_lteq, value} ->
          Query.issue_date_lteq(value)

        {:series_id, value} ->
          Query.by(:series_id, value)

        {:with_status, value} ->
          Query.by(:paid, value)
      end

    Repo.all(query)
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

  def get!(id, :preload), do: Repo.get!(Invoice, id) |> Repo.preload([:customer, :items, :series])

  @doc """
  Get a single invoice by the params
  """
  def get_by!(key, value) do
    Repo.get_by!(Invoice, %{key => value})
  end
end

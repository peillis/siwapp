defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.Invoices.{Invoice, Item, Query}
  alias Siwapp.Repo

  @doc """
  Gets a list of invoices by updated date
  """

  @spec list(none() | :preload) :: [Invoice.t()]
  def list do
    # query = Query.invoices()
    Repo.all(Invoice)
  end

  def list(:preload) do
    Repo.all(Query.list_preload())
  end

  @doc """
  Gets a list on the invoices that match with the params
  """

  @spec list_by(atom(), any()) :: [Invoice.t()]
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

  @spec get!(pos_integer(), none() | :preload) :: Invoice.t()
  def get!(id), do: Repo.get!(Invoice, id)

  def get!(id, :preload), do: Repo.get!(Invoice, id) |> Repo.preload([:customer, :items, :series])

  @doc """
  Get a single invoice by the params
  """

  @spec get_by!(atom(), any()) :: Invoice.t()
  def get_by!(key, value) do
    Repo.get_by!(Invoice, %{key => value})
  end

  @spec status(Invoice.t()) :: :draft | :failed | :paid | :pending | :past_due
  def status(invoice) do
    cond do
      invoice.draft -> :draft
      invoice.failed -> :failed
      invoice.paid -> :paid
      !is_nil(invoice.due_date) -> due_date_status(invoice.due_date)
      true -> :pending
    end
  end

  defp due_date_status(due_date) do
    if Date.diff(due_date, Date.utc_today()) > 0 do
      :pending
    else
      :past_due
    end
  end

  @doc """
  Gets an item by id
  """
  @spec get_item_by_id!(pos_integer()) :: Item.t()
  def get_item_by_id!(id), do: Repo.get!(Item, id)

  @doc """
  Creates an item associated to an invoice
  """
  def create_item(%Invoice{} = invoice, attrs \\ %{}) do
    invoice
    |> Ecto.build_assoc(:items)
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an item
  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Repo.preload(:taxes)
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an item
  """
  def delete_item(%Item{} = item), do: Repo.delete(item)
end

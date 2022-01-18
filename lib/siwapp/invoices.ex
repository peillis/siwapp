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

  def scroll_listing(page, per_page \\ 20) do
    Query.scroll_list_query(page, per_page) |> Repo.all()
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

  @spec create(map()) :: {:ok, Invoice.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an invoice
  """

  @spec update(Invoice.t(), map()) :: {:ok, Invoice.t()} | {:error, Ecto.Changeset.t()}
  def update(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an invoice
  """

  @spec delete(Invoice.t()) :: {:ok, Invoice.t()} | {:error, Ecto.Changeset.t()}
  def delete(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Gets an invoice by id
  """

  @spec get!(pos_integer(), none() | :preload) :: Invoice.t()
  def get!(id), do: Repo.get!(Invoice, id)

  def get!(id, :preload) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload([:customer, {:items, :taxes}, :series])

    items_with_calculations =
      invoice.items
      |> Enum.map(&change_item/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    Map.put(invoice, :items, items_with_calculations)
  end

  @doc """
  Get a single invoice by the params
  """

  @spec get_by!(atom(), any()) :: Invoice.t()
  def get_by!(key, value) do
    Repo.get_by!(Invoice, %{key => value})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.
  """
  def change(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
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

  @spec create_item(Invoice.t(), map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def create_item(%Invoice{} = invoice, attrs \\ %{}) do
    invoice
    |> Ecto.build_assoc(:items)
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an item
  """

  @spec update_item(Item.t(), map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def update_item(%Item{} = item, attrs) do
    item
    |> Repo.preload(:taxes)
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an item
  """

  @spec delete_item(Item.t()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def delete_item(%Item{} = item), do: Repo.delete(item)

  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end

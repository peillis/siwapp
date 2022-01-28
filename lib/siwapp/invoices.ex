defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.Invoices.{Invoice, InvoiceQuery, Item}
  alias Siwapp.Query
  alias Siwapp.Repo

  @doc """
  Gets a list of invoices by updated date
  """

  @spec list(none() | atom()) :: [Invoice.t()]
  def list do
    # query = Query.invoices()
    Repo.all(Invoice)
  end

  def list(assoc) do
    Invoice
    |> Query.list_preload(assoc)
    |> Repo.all()
  end

  def scroll_listing(page, per_page \\ 20) do
    Invoice
    |> Query.paginate(page, per_page)
    |> Repo.all()
  end

  @doc """
  Gets a list of the invoices by giving a list of tuples with {key, value}
  where the key is an atom
  """

  @spec list_by([{atom(), any()}]) :: list()
  def list_by(query_list) do
    Enum.reduce(query_list, Invoice, fn {field, value}, acc_query ->
      InvoiceQuery.list_by_query(acc_query, field, value)
    end)
    |> Repo.all()
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

  def get(id), do: Repo.get(Invoice, id)

  def get(id, preload: list) do
    Invoice
    |> Repo.get(id)
    |> Repo.preload(list)
  end

  @doc """
  Gets an invoice by id
  """

  @spec get!(pos_integer(), none() | keyword()) :: Invoice.t()
  def get!(id), do: Repo.get!(Invoice, id)

  def get!(id, preload: list) do
    invoice =
      Invoice
      |> Repo.get!(id)
      |> Repo.preload(list)

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

  def list_past_due(page, per_page \\ 20) do
    Invoice
    |> InvoiceQuery.list_past_due()
    |> Query.paginate(page, per_page)
    |> Repo.all()
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

  @spec set_currency(float | integer, atom | binary) :: binary
  def set_currency(value, nil), do: set_currency(value, :USD)

  def set_currency(value, currency) do
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string()
  end
end

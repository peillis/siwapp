defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.InvoiceHelper
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Invoices.InvoiceQuery
  alias Siwapp.Invoices.Item
  alias Siwapp.Query
  alias Siwapp.Repo

  @doc """
  Gets a list of invoices by updated date with the parameters included in the options
  """
  @spec list(keyword()) :: [Invoice.t()]
  def list(options \\ []) do
    default = [limit: 100, offset: 0, preload: [], filters: []]
    options = Keyword.merge(default, options)

    options[:filters]
    |> Enum.reduce(Invoice, fn {field, value}, acc_query ->
      InvoiceQuery.list_by_query(acc_query, field, value)
    end)
    |> limit(^options[:limit])
    |> offset(^options[:offset])
    |> Query.list_preload(options[:preload])
    |> Repo.all()
  end

  @spec scroll_listing(integer, integer) :: [Invoice.t()]
  def scroll_listing(page, per_page \\ 20) do
    Invoice
    |> Query.paginate(page, per_page)
    |> Query.list_preload(:series)
    |> Repo.all()
  end

  @spec count :: integer | nil
  def count do
    Repo.aggregate(Invoice, :count)
  end

  @doc """
  Creates an invoice
  """

  @spec create(map()) :: {:ok, Invoice.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Invoice{}
    |> change(attrs)
    |> InvoiceHelper.maybe_find_customer_or_new()
    |> Repo.insert()
  end

  @doc """
  Update an invoice
  """

  @spec update(Invoice.t(), map()) :: {:ok, Invoice.t()} | {:error, Ecto.Changeset.t()}
  def update(%Invoice{} = invoice, attrs) do
    invoice
    |> change(attrs)
    |> InvoiceHelper.maybe_find_customer_or_new()
    |> Repo.update()
  end

  @doc """
  Delete an invoice
  """

  @spec delete(Invoice.t()) :: {:ok, Invoice.t()} | {:error, Ecto.Changeset.t()}
  def delete(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  def send_email(invoice) do
    case Siwapp.InvoiceMailer.build_invoice_email(invoice) do
      {:error, msg} -> {:error, msg}
      {:ok, email} -> Siwapp.Mailer.deliver!(email)
    end
  end

  @spec get(pos_integer()) :: Invoice.t() | nil
  def get(id), do: Repo.get(Invoice, id)

  @spec get(pos_integer(), keyword()) :: Invoice.t() | nil
  def get(id, preload: list) do
    Invoice
    |> Repo.get(id)
    |> Repo.preload(list)
  end

  @doc """
  Gets an invoice by id
  """

  @spec get!(pos_integer() | binary()) :: Invoice.t()
  def get!(id), do: Repo.get!(Invoice, id)

  @spec get!(pos_integer(), keyword()) :: Invoice.t()
  def get!(id, preload: list) do
    invoice =
      Invoice
      |> Repo.get!(id)
      |> Repo.preload(list)

    items_with_calculations =
      Enum.map(invoice.items, &Ecto.Changeset.apply_changes(change_item(&1, invoice.currency)))

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
  @spec change(Invoice.t(), map) :: Ecto.Changeset.t()
  def change(%Invoice{} = invoice, attrs \\ %{}) do
    invoice
    |> Invoice.changeset(attrs)
    |> Invoice.assign_number()
  end

  @spec list_past_due(integer, integer) :: [Invoice.t()]
  def list_past_due(page, per_page \\ 20) do
    Invoice
    |> InvoiceQuery.list_past_due()
    |> Query.paginate(page, per_page)
    |> Query.list_preload(:series)
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

  @spec list_currencies :: [atom]
  def list_currencies do
    Money.Currency.all()
    |> Map.keys()
    |> Enum.sort()
  end

  @spec due_date_status(DateTime.t()) :: :pendig | :past_due
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

  @spec create_item(Invoice.t(), atom() | binary(), map()) ::
          {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def create_item(%Invoice{} = invoice, currency, attrs \\ %{}) do
    invoice
    |> Ecto.build_assoc(:items)
    |> Item.changeset(attrs, currency)
    |> Repo.insert()
  end

  @doc """
  Updates an item
  """

  @spec update_item(Item.t(), atom() | binary(), map()) ::
          {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def update_item(%Item{} = item, currency, attrs) do
    item
    |> Repo.preload(:taxes)
    |> Item.changeset(attrs, currency)
    |> Repo.update()
  end

  @doc """
  Deletes an item
  """

  @spec delete_item(Item.t()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def delete_item(%Item{} = item), do: Repo.delete(item)

  @spec change_item(Item.t(), binary | atom, map) :: Ecto.Changeset.t()
  def change_item(%Item{} = item, currency, attrs \\ %{}) do
    Item.changeset(item, attrs, currency)
  end
end

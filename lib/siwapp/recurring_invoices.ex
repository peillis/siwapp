defmodule Siwapp.RecurringInvoices do
  @moduledoc """
  Recurring Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.Query
  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Repo

  @spec list :: [RecurringInvoice.t()]
  def list do
    # query = Query.invoices()
    Repo.all(RecurringInvoice)
  end

  def scroll_listing(page, per_page \\ 20) do
    RecurringInvoice
    |> Query.paginate(page, per_page)
    |> Repo.all()
  end

  @spec get!(pos_integer()) :: RecurringInvoice.t()
  def get!(id), do: Repo.get!(RecurringInvoice, id)

  @spec get!(pos_integer(), :preload) :: RecurringInvoice.t()
  def get!(id, :preload),
    do: Repo.get!(RecurringInvoice, id) |> Repo.preload([:customer, :series])

  @spec create(map) :: {:ok, RecurringInvoice.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %RecurringInvoice{}
    |> RecurringInvoice.changeset(attrs)
    |> Repo.insert()
  end

  @spec update(RecurringInvoice.t(), map) ::
          {:ok, RecurringInvoice.t()} | {:error, Ecto.Changeset.t()}
  def update(recurring_invoice, attrs) do
    recurring_invoice
    |> RecurringInvoice.changeset(attrs)
    |> Repo.update()
  end

  @spec delete(RecurringInvoice.t() | Ecto.Changeset.t()) ::
          {:ok, RecurringInvoice.t()} | {:error, Ecto.Changeset.t()}
  def delete(recurring_invoice) do
    Repo.delete(recurring_invoice)
  end

  # Expect will be added when function is finished
  def generate_invoices(id) do
    Repo.get!(RecurringInvoice, id)
  end

  @spec change(RecurringInvoice.t(), map) :: Ecto.Changeset.t()
  def change(%RecurringInvoice{} = recurring_invoice, attrs \\ %{}) do
    RecurringInvoice.changeset(recurring_invoice, attrs)
  end

  @spec invoices_to_generate(pos_integer()) :: pos_integer()
  def invoices_to_generate(id) do
    rec_inv = get!(id)
    number_using_date = number_of_inv(rec_inv.starting_date, rec_inv.period, rec_inv.period_type, rec_inv.finishing_date)
    number_using_max = number_of_inv(rec_inv.starting_date, rec_inv.period, rec_inv.period_type, rec_inv.max_ocurrences)
  end

  @spec number_of_inv(Date.t(), integer, binary, Date.t | pos_integer()) :: non_neg_integer()
  defp number_of_inv(starting_date, period, period_type, %Date{} = finishing_date) do
    1
  end
  defp number_of_inv(starting_date, period, period_type, max_ocurrences) when is_integer(max_ocurrences) do
    0
  end
    
end

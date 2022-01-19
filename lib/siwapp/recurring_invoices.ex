defmodule Siwapp.RecurringInvoices do
  @moduledoc """
  Recurring Invoices context.
  """
  import Ecto.Query, warn: false
  import DateTime

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
    today =  to_date(utc_now)
    max_date = Date.add(starting_date, )
    if Date.compare(finishing_date, Date.add())
    number_using_date = number_of_inv_using_date(today, rec_inv.period, rec_inv.period_type, rec_inv.finishing_date)
    number_using_max = number_of_inv(rec_inv.starting_date, rec_inv.period, rec_inv.period_type, rec_inv.max_ocurrences)
  end

  #Right now returns the number of invoices to generate counting today but not the finishing_date
  defp number_of_inv(today, period, "Daily", %Date{} = max_date) do
    Stream.iterate(today, &( Date.add( &1, period) ))
    |> Enum.take_while( &Date.compare(&1, finishing_date) != :eq)
    |> length()
  end

  defp number_of_inv(today, period, "Monthly", %Date{} = max_date) do
    Stream.iterate(today, &( Date.add(&1, days_to_sum(&1, period)) ))
  end

end

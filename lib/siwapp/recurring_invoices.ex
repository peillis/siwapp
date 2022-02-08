defmodule Siwapp.RecurringInvoices do
  @moduledoc """
  Recurring Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.Invoices.{Invoice, InvoiceQuery}
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
    |> RecurringInvoice.untransform_items()
    |> Repo.insert()
  end

  @spec update(RecurringInvoice.t(), map) ::
          {:ok, RecurringInvoice.t()} | {:error, Ecto.Changeset.t()}
  def update(recurring_invoice, attrs) do
    recurring_invoice
    |> RecurringInvoice.changeset(attrs)
    |> RecurringInvoice.untransform_items()
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

  @doc """
  Given a recurring_invoice id, returns the amount of invoices that should
  be generated
  """
  @spec invoices_to_generate(pos_integer()) :: integer
  def invoices_to_generate(id) do
    theoretical_number_of_inv_generated(id) - generated_invoices(id)
  end

  # Given a recurring_invoice id, returns the amount of invoices already generated related to that recurring_invoice
  @spec generated_invoices(pos_integer()) :: non_neg_integer()
  defp generated_invoices(id) do
    Invoice
    |> InvoiceQuery.number_of_invoices_associated_to_recurring_id(id)
    |> Repo.one()
  end

  # Given a recurring_invoice id, returns the amount of invoices that
  # should have been generated from starting_date until today, both included
  @spec theoretical_number_of_inv_generated(pos_integer()) :: non_neg_integer()
  defp theoretical_number_of_inv_generated(id) do
    rec_inv = get!(id)
    today = Date.utc_today()

    max_date =
      [today, rec_inv.finishing_date]
      |> Enum.reject(&is_nil(&1))
      |> Enum.sort(Date)
      |> List.first()

    number_using_dates =
      number_of_invoices_in_between_dates(
        rec_inv.starting_date,
        rec_inv.period,
        rec_inv.period_type,
        max_date
      )

    if rec_inv.max_ocurrences,
      do: min(number_using_dates, rec_inv.max_ocurrences),
      else: number_using_dates
  end

  # Returns the number of invoices that should have been generated from starting_date until max_date both included
  @spec number_of_invoices_in_between_dates(Date.t(), pos_integer(), binary, Date.t()) ::
          pos_integer()
  defp number_of_invoices_in_between_dates(
         %Date{} = starting_date,
         period,
         period_type,
         %Date{} = max_date
       ) do
    Stream.iterate(starting_date, &next_date(&1, period, period_type))
    |> Enum.take_while(&(Date.compare(&1, max_date) != :gt))
    |> length()
  end

  # Returns the next date that invoices should be generated
  @spec next_date(Date.t(), pos_integer(), binary) :: Date.t()
  defp next_date(%Date{} = date, period, period_type),
    do: Date.add(date, days_to_sum_for_next(date, period, period_type))

  # Returns the days that should be added to get to the following invoices generating date
  @spec days_to_sum_for_next(Date.t(), pos_integer(), binary) :: pos_integer
  defp days_to_sum_for_next(_date, 0, _period_type), do: 0
  defp days_to_sum_for_next(_date, period, "Daily"), do: period

  defp days_to_sum_for_next(date, period, "Monthly") do
    days_this_month = :calendar.last_day_of_the_month(date.year, date.month)
    next_date = Date.add(date, days_this_month)
    days_this_month + days_to_sum_for_next(next_date, period - 1, "Monthly")
  end

  defp days_to_sum_for_next(date, period, "Yearly") do
    days_this_year = if Date.leap_year?(date), do: 366, else: 365
    next_date = Date.add(date, days_this_year)
    days_this_year + days_to_sum_for_next(next_date, period - 1, "Yearly")
  end
end

defmodule Siwapp.RecurringInvoices do
  @moduledoc """
  Recurring Invoices context.
  """
  import Ecto.Query, warn: false
  import DateTime

  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Repo

  @spec list :: [RecurringInvoice.t()]
  def list do
    # query = Query.invoices()
    Repo.all(RecurringInvoice)
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
    today = to_date(utc_now())

    max_date =
      cond do
        is_nil(rec_inv.max_ocurrences) && is_nil(rec_inv.finishing_date) ->
          [today, today]

        is_nil(rec_inv.max_ocurrences) ->
          [Date.add(rec_inv.finishing_date, 1), rec_inv.finishing_date]

        true ->
          date_max_ocurrences =
            date_from_max_ocurrences(
              rec_inv.starting_date,
              rec_inv.period,
              rec_inv.period_type,
              rec_inv.max_ocurrences
            )

          finishing_date =
            if is_nil(rec_inv.finishing_date),
              do: Date.add(date_max_ocurrences, 1),
              else: rec_inv.finishing_date

          [date_max_ocurrences, finishing_date]
      end
      |> Enum.sort(Date)
      |> List.first()

    number_of_inv(today, rec_inv.period, rec_inv.period_type, max_date)
  end

  # Right now returns the number of invoices to generate counting today but and the finishing_date
  @spec number_of_inv(Date.t(), pos_integer(), binary, Date.t()) :: pos_integer()
  defp number_of_inv(%Date{} = today, period, period_type, %Date{} = max_date) do
    Stream.iterate(today, &Date.add(&1, days_to_sum_for_next(&1, period, period_type)))
    |> Enum.take_while(&(Date.compare(&1, max_date) != :gt))
    |> length()
  end

  # Returns the theoretical date of max_ocurrences ending counting that first invoice is on starting_date
  @spec date_from_max_ocurrences(Date.t(), pos_integer(), binary, pos_integer()) :: Date.t()
  defp date_from_max_ocurrences(%Date{} = starting_date, _period, _period_type, 1),
    do: starting_date

  defp date_from_max_ocurrences(%Date{} = starting_date, period, period_type, max_ocurrences) do
    next_date = Date.add(starting_date, days_to_sum_for_next(starting_date, 1, period_type))
    date_from_max_ocurrences(next_date, period, period_type, max_ocurrences - 1)
  end

  @spec days_to_sum_for_next(Date.t(), pos_integer(), binary) :: pos_integer
  defp days_to_sum_for_next(_date, 0, _period_type), do: 0
  defp days_to_sum_for_next(_date, period, "Daily"), do: period

  defp days_to_sum_for_next(date, period, "Monthly") do
    days_this_month = :calendar.last_day_of_the_month(date.year, date.month)
    days_this_month + days_to_sum_for_next(Date.add(date, days_this_month), period - 1, "Monthly")
  end

  defp days_to_sum_for_next(date, period, "Yearly") do
    days_this_year = if Date.leap_year?(date), do: 366, else: 365
    days_this_year + days_to_sum_for_next(Date.add(date, days_this_year), period - 1, "Yearly")
  end
end

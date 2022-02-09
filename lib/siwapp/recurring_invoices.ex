defmodule Siwapp.RecurringInvoices do
  @moduledoc """
  Recurring Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.InvoiceHelper
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Invoices.InvoiceQuery
  alias Siwapp.Query
  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Repo

  @spec list(keyword()) :: [RecurringInvoice.t()]
  def list(options \\ []) do
    default = [limit: 100, offset: 0, preload: []]
    options = Keyword.merge(default, options)

    RecurringInvoice
    |> limit(^options[:limit])
    |> offset(^options[:offset])
    |> Query.list_preload(options[:preload])
    |> Repo.all()
  end

  @spec get!(pos_integer()) :: RecurringInvoice.t()
  def get!(id), do: Repo.get!(RecurringInvoice, id)

  @spec get!(pos_integer(), :preload) :: RecurringInvoice.t()
  def get!(id, :preload) do
    RecurringInvoice
    |> Repo.get!(id)
    |> Repo.preload([:customer, :series])
  end

  @spec create(map) :: {:ok, RecurringInvoice.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %RecurringInvoice{}
    |> RecurringInvoice.changeset(attrs)
    |> InvoiceHelper.maybe_find_customer_or_new()
    |> RecurringInvoice.untransform_items()
    |> Repo.insert()
  end

  @spec change(RecurringInvoice.t(), map) :: Ecto.Changeset.t()
  def change(%RecurringInvoice{} = recurring_invoice, attrs \\ %{}) do
    RecurringInvoice.changeset(recurring_invoice, attrs)
  end

  @spec update(RecurringInvoice.t(), map) ::
          {:ok, RecurringInvoice.t()} | {:error, Ecto.Changeset.t()}
  def update(recurring_invoice, attrs) do
    recurring_invoice
    |> RecurringInvoice.changeset(attrs)
    |> InvoiceHelper.maybe_find_customer_or_new()
    |> RecurringInvoice.untransform_items()
    |> Repo.update()
  end

  @spec delete(RecurringInvoice.t() | Ecto.Changeset.t()) ::
          {:ok, RecurringInvoice.t()} | {:error, Ecto.Changeset.t()}
  def delete(recurring_invoice) do
    Repo.delete(recurring_invoice)
  end

  @doc """
  Generates invoices associated to recurring_invoice, if this is enabled, and sends them
  by email if they are meant to (set in recurring_invoice send_by_email field)
  """
  @spec generate_invoices(pos_integer()) :: :ok
  def generate_invoices(id) do
    rec_inv = get!(id)

    id
    |> invoices_to_generate()
    |> Range.new(1, -1)
    |> Enum.map(fn _ -> Invoices.create(build_invoice_attrs(rec_inv)) end)
    |> Enum.each(fn {:ok, invoice} -> maybe_send_by_email(invoice, rec_inv.send_by_email) end)
  end

  @spec build_invoice_attrs(RecurringInvoice.t()) :: map
  defp build_invoice_attrs(rec_inv) do
    rec_inv
    |> Map.from_struct()
    |> Map.put(:recurring_invoice_id, rec_inv.id)
    |> maybe_add_due_date(rec_inv.days_to_due)
    |> Map.put(:items, rec_inv.items)
  end

  @spec maybe_add_due_date(map, integer) :: map
  defp maybe_add_due_date(attrs, days_to_due) do
    if days_to_due do
      due_date = Date.add(Date.utc_today(), days_to_due)
      Map.put(attrs, :due_date, due_date)
    else
      attrs
    end
  end

  @spec maybe_send_by_email(Invoice.t(), boolean) :: {:ok, pos_integer} | {:error, binary} | nil
  defp maybe_send_by_email(invoice, true) do
    invoice
    |> Repo.preload([{:items, :taxes}, :series])
    |> Invoices.send_email()
  end

  defp maybe_send_by_email(_invoice, _send_by_email), do: nil

  # Given a recurring_invoice id, returns the amount of invoices that should  be generated
  @spec invoices_to_generate(pos_integer()) :: integer
  def invoices_to_generate(id) do
    theoretical_number_of_inv_generated(id) - generated_invoices(id)
  end

  def filtered(value) do
    RecurringInvoice
    |> Query.name_email_or_id(value)
    |> Repo.all()
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
  # if recurring_invoice is enabled. Otherwise returns 0
  @spec theoretical_number_of_inv_generated(pos_integer()) :: non_neg_integer()
  defp theoretical_number_of_inv_generated(id) do
    rec_inv = get!(id)

    if rec_inv.enabled do
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
    else
      0
    end
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
    stream_iterate = Stream.iterate(starting_date, &next_date(&1, period, period_type))

    stream_iterate
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

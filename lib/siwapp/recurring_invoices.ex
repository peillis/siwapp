defmodule Siwapp.RecurringInvoices do
  @moduledoc """
  Recurring Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.Invoices.{Invoice, InvoiceQuery, Item}
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

  @spec change(RecurringInvoice.t(), map) :: Ecto.Changeset.t()
  def change(%RecurringInvoice{} = recurring_invoice, attrs \\ %{}) do
    RecurringInvoice.changeset(recurring_invoice, attrs)
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

  @doc """
  Generates invoices associated to recurring_invoice if this is enabled
  """
  def generate_invoices(id) do
    rec_inv = Repo.get!(RecurringInvoice, id)
    invoices_to_do = invoices_to_generate(id)
    for _i <- 1..invoices_to_do, do: if rec_inv.enabled, do: Repo.insert(build_invoice(rec_inv))
  end

  # Builds Invoice struct from recurring_invoice
  @spec build_invoice(RecurringInvoice.t()) :: Invoice.t()
  defp build_invoice(rec_inv) do
    common_parameters =
      rec_inv
      |> Map.from_struct()
      |> Map.to_list()
      |> Keyword.filter(fn {key, _value} -> Enum.member?(identical_fields(), key) end)
    keywords_invoice =
      common_parameters
      |> Keyword.put_new(:recurring_invoice_id, rec_inv.id)
      |> maybe_add_due_date(rec_inv.days_to_due)
      |> insert_items(rec_inv.items)
    struct(Invoice, keywords_invoice)
  end

  @spec maybe_add_due_date(Keyword.t(), integer) :: Keyword.t()
  defp maybe_add_due_date(keywords, days_to_due) do
    if days_to_due do
      due_date = Date.add(Date.utc_today(), days_to_due)
      Keyword.put_new(keywords, :due_date, due_date)
    else
      keywords
    end
  end

  @spec insert_items(Keyword.t()) :: Keyword.t()
  defp insert_items(keywords, []), do: keywords
  defp insert_items(keywords, list), do: keywords ++ [{:items, build_items(list)}]

  @spec build_items(list) :: [] | [Item.t()]
  defp build_items([]), do: []
  defp build_items([ h | t]) do
    item_parameters = translate_item_fields(h)
    [struct(Item, item_parameters)] ++ build_items(t)
  end

  @spec translate_item_fields(map) :: Keyword.t()
  defp translate_item_fields(%{"description" => d, "discount" => di, "quantity" => q, "taxes" => t, "unitary_cost" => u}) do
    taxes = Enum.map(t, &(Siwapp.Commons.get_tax_by_name(&1)))
  [{:description, d}, {:unitary_cost, String.to_integer(u)}, {:quantity, String.to_integer(q)}, {:discount, String.to_integer(di)}, {:taxes, taxes}]
  end

  @spec identical_fields :: Keyword.t()
  defp identical_fields, do: [:name, :identification, :email, :contact_person, :invoicing_address, :shipping_address, :net_amount, :gross_amount, :notes, :terms, :meta_attributes, :customer_id, :series_id, :currency]

  #Given a recurring_invoice id, returns the amount of invoices that should  be generated
  @spec invoices_to_generate(pos_integer()) :: integer
  defp invoices_to_generate(id) do
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

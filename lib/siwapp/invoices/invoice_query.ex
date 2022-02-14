defmodule Siwapp.Invoices.InvoiceQuery do
  @moduledoc """
  Invoices Querys
  """
  import Ecto.Query

  def list_past_due(query) do
    date_today = Date.utc_today()

    query
    |> where(draft: false)
    |> where(paid: false)
    |> where(failed: false)
    |> where([i], not is_nil(i.due_date))
    |> where([i], i.due_date < ^date_today)
  end

  def with_terms(query, terms) do
    query
    |> join(:left, [i], it in Siwapp.Invoices.Item, on: it.invoice_id == i.id)
    |> or_where([i, it], ilike(it.description, ^"%#{terms}%"))
    |> or_where([i], ilike(i.email, ^"%#{terms}%"))
    |> or_where([i], ilike(i.name, ^"%#{terms}%"))
    |> or_where([i], ilike(i.identification, ^"%#{terms}%"))
    |> distinct([i], i.id)
  end

  def issue_date_gteq(query, date) do
    query
    |> where([i], i.issue_date >= ^date)
  end

  def issue_date_lteq(query, date) do
    query
    |> where([i], i.issue_date <= ^date)
  end

  @spec last_number_with_series_id(Ecto.Queryable.t(), pos_integer()) :: Ecto.Query.t()
  def last_number_with_series_id(query, series_id) do
    query
    |> where(series_id: ^series_id)
    |> order_by(desc: :number)
    |> limit(1)
  end

  @doc """
  Gets a query on the invoices that match with the params
  """
  def list_by_query(query, key, value) do
    case {key, value} do
      {:with_terms, value} ->
        with_terms(query, value)

      {:customer_id, value} ->
        where(query, customer_id: ^value)

      {:issue_date_gteq, value} ->
        issue_date_gteq(query, value)

      {:issue_date_lteq, value} ->
        issue_date_lteq(query, value)

      {:series_id, value} ->
        where(query, series_id: ^value)

      {:with_status, :past_due} ->
        date_today = Date.utc_today()

        where(query, [i], not is_nil(i.due_date))
        |> where([i], i.due_date < ^date_today)

      {:with_status, value} ->
        where(query, ^[{value, true}])
    end
  end

  @spec number_of_invoices_associated_to_recurring_id(Ecto.Queryable.t(), pos_integer()) ::
          Ecto.Query.t()
  def number_of_invoices_associated_to_recurring_id(query, recurring_invoice_id) do
    query
    |> where(recurring_invoice_id: ^recurring_invoice_id)
    |> select([q], count(q.id))
  end
end

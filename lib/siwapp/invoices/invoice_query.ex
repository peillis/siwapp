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
    |> join(:inner, [i], it in Siwapp.Invoices.Item)
    |> where([i, it], ilike(it.description, ^"%#{terms}%"))
    |> or_where([i], ilike(i.email, ^"%#{terms}%"))
    |> or_where([i], ilike(i.name, ^"%#{terms}%"))
    |> or_where([i], ilike(i.identification, ^"%#{terms}%"))
  end

  def issue_date_gteq(query, date) do
    query
    |> where([i], i.issue_date >= ^date)
  end

  def issue_date_lteq(query, date) do
    query
    |> where([i], i.issue_date <= ^date)
  end

  @spec last_number_with_series_id(any, pos_integer()) :: Ecto.Query.t()
  def last_number_with_series_id(query, series_id) do
    query
    |> where(series_id: ^series_id)
    |> order_by(desc: :number)
    |> limit(1)
  end
end
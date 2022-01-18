defmodule Siwapp.Invoices.Query do
  @moduledoc """
  Invoices Querys
  """
  import Ecto.Query

  def list_preload(query, term) do
    preload(query, ^term)
  end

  def paginate(query, page, per_page) do
    offset_by = per_page * page

    query
    |> limit(^per_page)
    |> offset(^offset_by)
  end

  def scroll_list_query(query, page, per_page \\ 20) do
    query
    |> paginate(page, per_page)
  end

  def by(query, field, value) do
    query
    |> where(^[{field, value}])
  end

  def list_past_due_or_pending(query) do
    query
    |> where(draft: false)
    |> where(paid: false)
    |> where(failed: false)
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

  @spec last_number_with_series_id(pos_integer()) :: Ecto.Query.t()
  def last_number_with_series_id(series_id) do
    Invoice
    |> where(series_id: ^series_id)
    |> Ecto.Query.order_by(desc: :number)
    |> Ecto.Query.limit(1)
  end
end

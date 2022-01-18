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
    from(c in query) |> paginate(page, per_page)
  end

  def by(query, field, value) do
    query
    |> where(^[{field, value}])
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
end

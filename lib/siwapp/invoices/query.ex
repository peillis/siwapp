defmodule Siwapp.Invoices.Query do
  @moduledoc """
  Invoices Querys
  """
  alias Siwapp.Invoices.Invoice

  import Ecto.Query

  def list_preload do
    from i in Invoice,
      join: c in assoc(i, :customer),
      preload: [customer: c]
  end

  def paginate(query, page, per_page) do
    offset_by = per_page * page

    query
    |> limit(^per_page)
    |> offset(^offset_by)
  end

  def scroll_list_query(page, per_page \\ 20) do
    from(c in Invoice) |> paginate(page, per_page)
  end

  def by(field, value) do
    where(Invoice, ^[{field, value}])
  end

  def with_terms(terms) do
    from(i in Invoice,
      join: it in Siwapp.Invoices.Item,
      where: ilike(it.description, ^"%#{terms}%"),
      or_where: ilike(i.email, ^"%#{terms}%"),
      or_where: ilike(i.name, ^"%#{terms}%"),
      or_where: ilike(i.identification, ^"%#{terms}%")
    )
  end

  def issue_date_gteq(date) do
    from(i in Invoice,
      where: i.issue_date >= ^date
    )
  end

  def issue_date_lteq(date) do
    from(i in Invoice,
      where: i.issue_date <= ^date
    )
  end

  @spec last_number_with_series_id(pos_integer()) :: Ecto.Query.t()
  def last_number_with_series_id(series_id) do
    Invoice
    |> where(series_id: ^series_id)
    |> Ecto.Query.order_by(desc: :number)
    |> Ecto.Query.limit(1)
  end
end

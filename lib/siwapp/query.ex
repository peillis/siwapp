defmodule Siwapp.Query do
  @moduledoc """
  Generic Querys
  """
  import Ecto.Query

  def paginate(query, page, per_page) do
    offset_by = per_page * page

    query
    |> limit(^per_page)
    |> offset(^offset_by)
  end

  def by(query, field, value) do
    query
    |> where(^[{field, value}])
  end

  def list_preload(query, term) do
    preload(query, ^term)
  end

  def search_in_string(query, string_field, search) do
    query
    |> where([q], ilike(field(q, ^string_field), ^search))
  end

  def name_email_or_id(query, value) do
    query
    |> where([q], ilike(q.name, ^"%#{value}%"))
    |> or_where([q], ilike(q.email, ^"%#{value}%"))
    |> or_where([q], ilike(q.identification, ^"%#{value}%"))
  end
end

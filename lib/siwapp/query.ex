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

  def by(query, field, value), do: where(query, ^[{field, value}])

  def list_preload(query, term) do
    preload(query, ^term)
  end

  def search_in_string(query, string_field, search) do
    where(query, [q], ilike(field(q, ^string_field), ^search))
  end
end

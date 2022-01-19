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
end

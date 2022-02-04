defmodule Siwapp.Query do
  @moduledoc """
  Generic Querys
  """
  import Ecto.Query

  @spec paginate(Ecto.Queryable.t(), integer, integer) :: Ecto.Query.t()
  def paginate(query, page, per_page) do
    offset_by = per_page * page

    query
    |> limit(^per_page)
    |> offset(^offset_by)
  end

  @spec by(Ecto.Queryable.t(), atom, any) :: Ecto.Query.t()
  def by(query, field, value), do: where(query, ^[{field, value}])

  @spec list_preload(Ecto.Queryable.t(), atom | [atom]) :: Ecto.Query.t()
  def list_preload(query, term) do
    preload(query, ^term)
  end

  @spec search_in_string(Ecto.Queryable.t(), atom, binary) :: Ecto.Query.t()
  def search_in_string(query, string_field, search) do
    where(query, [q], ilike(field(q, ^string_field), ^search))
  end

  def name_email_or_id(query, value) do
    query
    |> where([q], ilike(q.name, ^"%#{value}%"))
    |> or_where([q], ilike(q.email, ^"%#{value}%"))
    |> or_where([q], ilike(q.identification, ^"%#{value}%"))
  end
end

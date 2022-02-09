defmodule Siwapp.Query do
  @moduledoc """
  Generic Querys
  """
  import Ecto.Query

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

  @spec not_deleted(Ecto.Queryable.t()) :: Ecto.Query.t()
  def not_deleted(query) do
    where(query, [q], is_nil(q.deleted_at))
  end

end

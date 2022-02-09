defmodule Siwapp.Search do
  @moduledoc """
  Context for
  """
  alias Siwapp.{Query, Repo}
  alias Siwapp.Search.SearchQuery

  def filters(query, value, view) do
    query
    |> SearchQuery.name_email_or_id(value)
    |> maybe_preload(view)
    |> Repo.all()
  end

  def maybe_preload(query, view) do
    if view in [:invoice, :recurring_invoice] do
      Query.list_preload(query, :series)
    else
      query
    end
  end
end

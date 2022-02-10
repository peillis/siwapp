defmodule Siwapp.Search do
  @moduledoc """
  Context for
  """
  alias Siwapp.{Query, Repo}
  alias Siwapp.Search.SearchQuery

  def filters(query, value) do
    query
    |> SearchQuery.name_email_or_id(value)
    |> maybe_preload()
    |> Repo.all()
  end

  def maybe_preload(query) do
    {view, _} = query.from.source

    if view in ["invoices", "recurring_invoices"] do
      Query.list_preload(query, :series)
    else
      query
    end
  end
end

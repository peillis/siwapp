defmodule Siwapp.Search do
  @moduledoc """

  Search Context
  """
  alias Siwapp.Query
  alias Siwapp.Repo
  alias Siwapp.Search.SearchQuery

<<<<<<< HEAD
  @doc """
  Filter invoices, customers or recurring_invoices by the selected parameters
  """
  @spec filters(Ecto.Queryable.t(), binary) :: list
  def filters(Siwapp.Customers.Customer = customer, value) do
    customer
    |> SearchQuery.name_email_or_id(value)
    |> Repo.all()
  end

  def filters(query, value) do
    query
    |> SearchQuery.name_email_or_id(value)
    |> Query.list_preload(:series)
    |> Repo.all()
=======
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
>>>>>>> dbd416d (2 arguments instead of 1 in filters function)
  end
end

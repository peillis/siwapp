defmodule Siwapp.Search do
  @moduledoc """
  Search Context
  """
  alias Siwapp.Query
  alias Siwapp.Repo
  alias Siwapp.Search.SearchQuery

  @doc """
  Filter invoices, customers or recurring_invoices by the selected parameters  """

  @spec filters(Ecto.Queryable.t(), binary) :: list
  def filters(Siwapp.Customers.Customer = customer, params) do
    params
    |> Enum.reduce(customer, fn {key, value}, acc_query ->
      SearchQuery.filter_by(acc_query, key, value)
    end)
    |> Repo.all()
  end

  def filters(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, acc_query ->
      SearchQuery.filter_by(acc_query, key, value)
    end)
    |> Query.list_preload(:series)
    |> Repo.all()
  end
end

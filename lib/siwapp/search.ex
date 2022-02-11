defmodule Siwapp.Search do
  @moduledoc """

  Search Context
  """
  alias Siwapp.{Query, Repo}
  alias Siwapp.Search.SearchQuery

  @doc """
  Filter invoices, customers or recurring_invoices by the selected parameters
  """
  def filters(Siwapp.Customers.Customer = customer, values) do
    values
    |> Enum.reduce(customer, fn {key, value}, acc_query ->
      SearchQuery.filter_by(acc_query, key, value)
    end)
    |> Repo.all()
  end

  def filters(query, values) do
    values
    |> Enum.reduce(query, fn {key, value}, acc_query ->
      SearchQuery.filter_by(acc_query, key, value)
    end)
    |> Query.list_preload(:series)
    |> Repo.all()
  end
end

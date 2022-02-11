defmodule Siwapp.Search do
  @moduledoc """
  Search Context
  """
  alias Siwapp.{Query, Repo}
  alias Siwapp.Search.SearchQuery

  @doc """
  Filter invoices, customers or recurring_invoices by the selected parameters
  """
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
  end
end

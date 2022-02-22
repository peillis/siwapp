defmodule Siwapp.Search do
  @moduledoc """
  Search Context
  """
  alias Siwapp.Query
  alias Siwapp.Repo
  alias Siwapp.Search.SearchQuery

  @type type_of_struct ::
          Siwapp.Invoices.Invoice.t()
          | Siwapp.Customers.Customer.t()
          | Siwapp.RecurringInvoices.RecurringInvoice.t()
  @type key :: binary()
  @type value :: binary()
  @doc """
  Filter invoices, customers or recurring_invoices by the selected parameters
  """
  @spec filters(Ecto.Queryable.t(), [{key, value}]) :: [type_of_struct()]
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

  @spec get_customers_names(Ecto.Queryable.t(), binary, non_neg_integer) :: list()
  def get_customers_names(query, value, page) do
    query
    |> SearchQuery.customers_names(value, page)
    |> Repo.all()
  end
end

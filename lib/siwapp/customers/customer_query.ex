defmodule Siwapp.Customers.CustomerQuery do
  @moduledoc """
  Module to manage Customer queries
  """
  alias Siwapp.Customers.Customer

  import Ecto.Query

  @doc """
  Query to get customers in db, ordered desc. by id with limit and offset
  """
  @spec list(non_neg_integer(), non_neg_integer()) :: Ecto.Query.t()
  def list(limit, offset) do
    Customer
    |> order_by(desc: :id)
    |> limit(^limit)
    |> offset(^offset)
  end

  @doc """
  Query to get customers in db, ordered desc. by id with limit and offset
  just selecting fields: id, name, identification; and virtual fields: total,
  paid and currencies (sum of gross amount, sum of paid amount and list of
  all currencies, respectively, used in all invoices associated to customer)
  """
  @spec list_with_assoc_invoice_fields(non_neg_integer(), non_neg_integer()) :: Ecto.Query.t()
  def list_with_assoc_invoice_fields(limit, offset) do
    list(limit, offset)
    |> join(:left, [c], i in assoc(c, :invoices))
    |> where([c, i], not (i.draft or i.failed))
    |> group_by([c, i], c.id)
    |> select([c, i], %Customer{
      total: sum(i.gross_amount),
      paid: sum(i.paid_amount),
      currencies: fragment("array_agg(?)", i.currency),
      name: c.name,
      identification: c.identification,
      id: c.id
    })
  end
end

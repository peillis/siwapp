defmodule Siwapp.Customers.CustomerQuery do
  @moduledoc """
  Module to manage Customer queries
  """
  alias Siwapp.Customers.Customer

  import Ecto.Query

  def list(limit, offset) do
    Customer
    |> order_by(desc: :id)
    |> limit(^limit)
    |> offset(^offset)
  end

  def list_for_index(limit, offset) do
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

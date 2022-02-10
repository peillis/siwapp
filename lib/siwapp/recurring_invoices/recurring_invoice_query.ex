defmodule Siwapp.RecurringInvoices.RecurringInvoiceQuery do
  @moduledoc """
  Recurring Invoices queries
  """
  import Ecto.Query

  def starting_date_gteq(query, date) do
    query
    |> where([q], q.starting_date >= ^date)
  end

  def starting_date_lteq(query, date) do
    query
    |> where([q], q.starting_date <= ^date)
  end

  def finishing_date_gteq(query, date) do
    query
    |> where([q], q.finishing_date >= ^date)
  end

  def finishing_date_lteq(query, date) do
    query
    |> where([q], q.finishing_date <= ^date)
  end
end

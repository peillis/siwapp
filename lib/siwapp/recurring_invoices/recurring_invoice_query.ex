defmodule Siwapp.RecurringInvoices.RecurringInvoiceQuery do
  @moduledoc """
  Recurring Invoices queries
  """
  import Ecto.Query

  @spec starting_date_gteq(Ecto.Queryable.t(), Date.t()) :: Ecto.Query.t()
  def starting_date_gteq(query, date) do
    where(query, [q], q.starting_date >= ^date)
  end

  @spec starting_date_lteq(Ecto.Queryable.t(), Date.t()) :: Ecto.Query.t()
  def starting_date_lteq(query, date) do
    where(query, [q], q.starting_date <= ^date)
  end

  @spec finishing_date_gteq(Ecto.Queryable.t(), Date.t()) :: Ecto.Query.t()
  def finishing_date_gteq(query, date) do
    where(query, [q], q.finishing_date >= ^date)
  end

  @spec finishing_date_lteq(Ecto.Queryable.t(), Date.t()) :: Ecto.Query.t()
  def finishing_date_lteq(query, date) do
    where(query, [q], q.finishing_date <= ^date)
  end
end

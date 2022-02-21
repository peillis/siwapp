defmodule Siwapp.Invoices.Statistics do
  @moduledoc """
  Statistics utils.
  """
  import Ecto.Query

  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Repo

  @spec count(Ecto.Queryable.t()) :: non_neg_integer()
  def count(query) do
    Repo.aggregate(query, :count)
  end

  @doc """
  Returns a list of tuples, each containing the accumulated amount of money from all the invoices
  per day, for the given selection of 'invoices'.
  """
  @spec get_amount_per_day(Ecto.Queryable.t()) :: [tuple()]
  def get_amount_per_day(query \\ Invoice) do
    today = Date.utc_today()

    amount_per_date =
      query
      |> group_by([q], q.issue_date)
      |> select([q], %{date: q.issue_date, amount: sum(q.gross_amount)})

    amount_per_date
    |> subquery()
    |> join(
      :right,
      [q],
      d in fragment(
        "select i.date from generate_series(current_date - interval '30 day', current_date, '1 day') as i"
      ),
      on: q.date == d.date
    )
    |> select([q, d], {d.date, coalesce(q.amount, 0)})
    |> Repo.all()
  end

  @doc """
  Returns a map in which each key is the string of a currency code and its value the accumulated amount
  corresponding to all the 'invoices' in that currency.
  """
  @spec get_amount_per_currencies(Ecto.Queryable.t()) :: %{String.t() => integer()}
  def get_amount_per_currencies(query \\ Invoice) do
    query
    |> group_by([q], q.currency)
    |> select([q], {q.currency, sum(q.gross_amount)})
    |> Repo.all()
    |> Map.new()
  end
end

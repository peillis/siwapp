defmodule Siwapp.Invoices.Statistics do
  @moduledoc """
  Statistics utils.
  """
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice

  @doc """
  Returns a list of tuples, each containing the accumulated amount of money from all the invoices
  per day, for the given selection of 'invoices'.
  """
  @spec get_data_for_a_month([Invoice.t()]) :: [tuple()]
  def get_data_for_a_month(invoices \\ Invoices.list()) do
    invoices
    |> Enum.map(&Map.take(&1, [:issue_date, :gross_amount]))
    |> accumulate_amounts()
    |> set_time_scale(30)
    |> Enum.map(&{&1.issue_date, &1.gross_amount / 100})
  end

  @doc """
  Returns a map in which each key is the string of a currency code and its value the accumulated amount
  corresponding to all the 'invoices' in that currency.
  """
  @spec get_accumulated_amount_per_currencies([Invoice.t()]) :: %{String.t() => integer()}
  def get_accumulated_amount_per_currencies(invoices \\ Invoices.list()) do
    invoices
    |> Enum.sort_by(& &1.currency)
    |> Enum.chunk_by(& &1.currency)
    |> Enum.map(&{hd(&1).currency, sum_amounts(&1)})
    |> Map.new()
  end

  # We need this function so we have data (with amount = 0) for those days we have no invoices.
  # First, we create a series of graphic points with amounts of 0 for the given 'days'. Then we join
  # them with the actual data from database.
  @spec set_time_scale([map()], non_neg_integer()) :: [map()]
  defp set_time_scale(invoices_data, days) do
    Date.utc_today()
    |> Date.add(-days)
    |> Date.range(Date.utc_today())
    |> Enum.map(fn day ->
      Map.merge(
        %{issue_date: day, gross_amount: 0},
        Enum.find(invoices_data, %{}, &(&1[:issue_date] == day))
      )
    end)
  end

  # We have an unique graphic point with the sum of the amounts of all the invoices per day
  @spec accumulate_amounts([map()]) :: [map()]
  defp accumulate_amounts(data) do
    data
    |> Enum.group_by(& &1[:issue_date])
    |> Map.values()
    |> Enum.map(&%{issue_date: hd(&1).issue_date, gross_amount: sum_amounts(&1)})
  end

  @spec sum_amounts([map()]) :: non_neg_integer()
  defp sum_amounts(invoices) do
    Enum.sum(Enum.map(invoices, & &1.gross_amount))
  end
end

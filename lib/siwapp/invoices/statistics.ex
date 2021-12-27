defmodule Siwapp.Invoices.Statistics do
  alias Siwapp.Invoices

  @doc """
  Returns a list of tuples, each containing the accumulated amount of money from all the invoices
  per day. You can pass a param 'days' with the time scale you want this data to be scaled to (31
  by default).
  """
  @spec get_data(pos_integer()) :: [tuple()]
  def get_data(days \\ 31)

  def get_data(days) do
    Invoices.list()
    |> Enum.map(&Map.take(&1, [:issue_date, :gross_amount]))
    |> accumulate_amounts()
    |> set_time_scale(days)
    |> to_tuple()
  end

  # We need this function so we have data (with amount = 0) for those days we have no invoices.
  # First, we create a series of graphic points with amounts of 0 for the given 'days'. Then we join
  # them with the actual data from database.
  @spec set_time_scale([map()], non_neg_integer()) :: [map()]
  defp set_time_scale(invoices_data, days) do
    Date.utc_today()
    |> Date.add(-days)
    |> Date.range(Date.utc_today())
    |> Enum.map(&%{issue_date: &1, gross_amount: 0})
    |> Enum.map(fn day ->
      Map.merge(day, Enum.find(invoices_data, %{}, &(&1[:issue_date] == day[:issue_date])))
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
  defp sum_amounts(day) do
    Enum.sum(Enum.map(day, & &1.gross_amount))
  end

  @spec to_tuple([map()]) :: [tuple()]
  defp to_tuple(data) do
    Enum.map(data, &{&1.issue_date, &1.gross_amount})
  end
end

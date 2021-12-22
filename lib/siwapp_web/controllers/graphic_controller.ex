defmodule SiwappWeb.GraphicController do
  alias Contex.{LinePlot, Plot, Dataset}
  alias Siwapp.Invoices

  def plot() do
    options = [
      data_labels: false,
      default_style: false,
      smoothed: false
    ]

    Invoices.list()
    |> Enum.map(&Map.take(&1, [:issue_date, :gross_amount]))
    |> get_data_for_a_month()
    |> date_to_Naive_type()
    |> accumulate_amounts()
    |> Dataset.new()
    |> Plot.new(LinePlot, 500, 200, options)
    |> Plot.to_svg()
  end

  # We need this function so we have data (with amount = 0) for those days we have no invoices.
  # First, we create a month of graphic points with amounts of 0. Then we join them with the actual data from database.
  @spec get_data_for_a_month([map()]) :: [map()]
  defp get_data_for_a_month(invoices_data) do
    Date.utc_today()
    |> Date.add(-31)
    |> Date.range(Date.utc_today())
    |> Enum.map(&%{issue_date: &1, gross_amount: 0})
    |> Enum.map(fn day ->
      Map.merge(day, Enum.find(invoices_data, %{}, &(&1[:issue_date] == day[:issue_date])))
    end)
  end

  # This is necessary because Contex.DateScale only accepts DateTime or NaiveDateTime types.
  @spec date_to_Naive_type([map()]) :: [map()]
  defp date_to_Naive_type(data) do
    data
    |> Enum.map(fn %{issue_date: x} = day_data ->
      %{day_data | issue_date: NaiveDateTime.new!(x, ~T[00:00:00])}
    end)
  end

  # We have an unique graphic point with the sum of the amounts of all the invoices per day
  @spec accumulate_amounts([map()]) :: [tuple()]
  defp accumulate_amounts(data) do
    data
    |> Enum.group_by(& &1[:issue_date])
    |> Map.values()
    |> Enum.map(&{hd(&1).issue_date, sum_amounts(&1)})
  end

  @spec sum_amounts([map()]) :: non_neg_integer()
  defp sum_amounts(day) do
    Enum.sum(Enum.map(day, & &1.gross_amount))
  end
end

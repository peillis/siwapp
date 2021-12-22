defmodule SiwappWeb.GraphicController do

  alias Contex.{LinePlot, Plot, Dataset, TimeScale}
  alias Siwapp.Invoices

  def plot() do
    options = [
      data_labels: false,
      default_style: false,
      smoothed: false
    ]

      Invoices.list()
      |> Enum.map(&(Map.take(&1, [:issue_date, :gross_amount])))
      |> Enum.map(fn %{issue_date: x} = data -> %{data | issue_date: elem(NaiveDateTime.new(x, ~T[00:00:00]), 1)} end)
      |> IO.inspect
      |> accumulate_amounts()
      |> Dataset.new()
      |> Plot.new(LinePlot, 500, 200, options)
      |> Plot.to_svg()
  end

  defp accumulate_amounts(data) do
    data
    |> Enum.group_by(&(&1[:issue_date]))
    |> Map.values()
    |> Enum.map(&({hd(&1).issue_date, sum_amounts(&1)}))
    |> IO.inspect
  end

  defp sum_amounts(list) do
    Enum.sum(Enum.map(list, &(&1.gross_amount)))
  end

end

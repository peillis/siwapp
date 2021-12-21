defmodule SiwappWeb.GraphicController do

  alias Contex.{BarChart, Plot, Dataset}
  alias Siwapp.Invoices

  def plot() do
    options = [
      mapping: %{category_col: :issue_date, value_cols: [:gross_amount]},
      data_labels: false,
      colour_palette: ["bbd5ec"],
      default_style: false,
    ]

    invoices_data =
      Invoices.list()
      |> Enum.map(&(Map.take(&1, [:issue_date, :gross_amount])))

    Date.utc_today
    |> Date.add(-30)
    |> Date.range(Date.utc_today)
    |> Enum.map(&( %{issue_date: &1, gross_amount: 0}))
    |> Enum.map(fn value -> Map.merge(value, Enum.find(invoices_data, %{}, &(&1[:issue_date] == value[:issue_date]))) end)
    |> Enum.map(fn %{issue_date: x} = data -> %{data | issue_date: Calendar.strftime(x, "%d %b")} end)
    |> Dataset.new()
    |> Plot.new(BarChart, 500, 200, options)
    |> Plot.to_svg()
  end

end

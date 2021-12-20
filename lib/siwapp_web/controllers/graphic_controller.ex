defmodule SiwappWeb.GraphicController do

  alias Contex.{BarChart, Plot, Dataset}

  def plot() do
    options = [
      data_labels: false,
    ]

    data =
      [{"2021-12-13", 10_000}, {"2021-12-14", 20_000}, {"2021-12-15", 5_000}]
      |> Dataset.new(["amount", "day"])

    data
    |> Plot.new(BarChart, 500, 400, options)
    |> Plot.axis_labels("", "$")
    |> Plot.to_svg()
  end

end

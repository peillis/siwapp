defmodule SiwappWeb.GraphicHelpers do
  @moduledoc false
  alias Contex.Dataset
  alias Contex.LinePlot
  alias Contex.Plot

  @doc """
  Returns a SVG graphic of a line plot (500x200 size) with the given 'data'.

  'data' must be a list of tuples with size of 2.
  """
  @spec line_plot([{any(), any()}]) :: {:safe, [...]}
  def line_plot(data) do
    options = [
      data_labels: false,
      default_style: false,
      stroke_width: 1,
      smoothed: false
    ]

    margins = %{left: 35, right: 15, top: 10, bottom: 20}

    data
    |> Dataset.new()
    |> Plot.new(LinePlot, 500, 150, options)
    |> Map.put(:margins, margins)
    |> Plot.to_svg()
  end
end

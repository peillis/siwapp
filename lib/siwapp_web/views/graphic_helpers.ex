defmodule SiwappWeb.GraphicHelpers do
  alias Contex.{LinePlot, Plot, Dataset}

  @doc """
  Returns a SVG graphic of a line plot (500x200 size) with the given 'data'.

  'data' must be a list of tuples with size of 2.
  """
  @spec line_plot([{any(), any()}]) :: {:safe, [...]}
  def line_plot(data) do
    options = [
      data_labels: false,
      default_style: false,
      smoothed: false
    ]

    data
    |> Dataset.new()
    |> Plot.new(LinePlot, 500, 200, options)
    |> Plot.to_svg()
  end

end

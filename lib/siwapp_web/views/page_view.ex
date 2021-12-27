defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  alias SiwappWeb.GraphicHelpers
  alias Siwapp.Invoices

  @spec dashboard_chart :: {:safe, [...]}
  def dashboard_chart() do
    Invoices.Statistics.get_data()
    |> date_to_Naive_type()
    |> GraphicHelpers.line_plot()
  end

  # This is necessary because Contex.DateScale only accepts DateTime or NaiveDateTime types.
  @spec date_to_Naive_type([map()]) :: [map()]
  defp date_to_Naive_type(data) do
    data
    |> Enum.map(fn {date, amount} -> {NaiveDateTime.new!(date, ~T[00:00:00]), amount} end)
  end
end

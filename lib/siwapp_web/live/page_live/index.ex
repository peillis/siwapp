defmodule SiwappWeb.PageLive.Index do
  @moduledoc """
  This module manages the invoices LiveView events
  """
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias SiwappWeb.GraphicHelpers

  @doc """
  Creates the dashboard chart with information about invoices (amounts of money per day).
  """
  @spec dashboard_chart :: {:safe, [...]}
  def dashboard_chart do
    Invoices.Statistics.get_data()
    |> Enum.map(&date_to_naive_type/1)
    |> GraphicHelpers.line_plot()
  end

  # This is necessary because Contex.DateScale only accepts DateTime or NaiveDateTime types.
  @spec date_to_naive_type({Date.t(), integer()}) :: {NaiveDateTime.t(), integer()}
  defp date_to_naive_type({date, amount}) do
    {NaiveDateTime.new!(date, ~T[00:00:00]), amount}
  end
end

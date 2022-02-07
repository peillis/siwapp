defmodule SiwappWeb.PageLive.Index do
  @moduledoc """
  This module manages the invoices LiveView events
  """
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias SiwappWeb.GraphicHelpers

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:invoices, Invoices.list_past_due(0))}
  end

  @doc """
  Creates the dashboard chart with information about invoices (amounts of money per day).
  """
  @spec dashboard_chart :: {:safe, [...]}
  def dashboard_chart do
    Invoices.Statistics.get_data()
    |> Enum.map(&GraphicHelpers.date_to_naive_type/1)
    |> GraphicHelpers.line_plot()
  end

  def handle_event("load-more", _, socket) do
    %{
      page: page,
      invoices: invoices
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        invoices: invoices ++ Invoices.list_past_due(page + 1),
        page: page + 1
      )
    }
  end

end

defmodule SiwappWeb.PageLive.Index do
  @moduledoc """
  This module manages the invoices LiveView events
  """
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias SiwappWeb.GraphicHelpers

  @spec mount(map(), map, Phoenix.LiveView.Socket.t()) ::
          {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(
       :invoices,
       Invoices.list(limit: 20, offset: 0, preload: [:series], filters: [with_status: :past_due])
     )}
  end

  @doc """
  Creates the dashboard chart with information about invoices (amounts of money per day).
  """
  @spec dashboard_chart :: {:safe, [...]}
  def dashboard_chart do
    Invoices.Statistics.get_amount_per_day()
    |> Enum.map(fn {date, amount} -> {NaiveDateTime.new!(date, ~T[00:00:00]), amount} end)
    |> GraphicHelpers.line_plot(
      y_formatter:
        &SiwappWeb.PageView.money_format(&1, "USD", symbol: false, fractional_unit: false)
    )
  end

  @spec handle_event(binary, map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()} | {:reply, map(), Phoenix.LiveView.Socket.t()}
  def handle_event("load-more", _, socket) do
    %{
      page: page,
      invoices: invoices
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        invoices:
          invoices ++
            Invoices.list(
              limit: 20,
              offset: (page + 1) * 20,
              preload: [:series],
              filters: [with_status: :past_due]
            ),
        page: page + 1
      )
    }
  end
end

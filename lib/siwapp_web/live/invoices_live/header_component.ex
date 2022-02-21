defmodule SiwappWeb.HeaderComponent do
  @moduledoc false
  use SiwappWeb, :live_component

  alias SiwappWeb.GraphicHelpers
  alias SiwappWeb.PageView
  alias Siwapp.Invoices.Statistics

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(summary_state: set_summary(:closed))
     |> assign(default_currency: Siwapp.Settings.value(:currency))}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    totals = Statistics.get_amount_per_currencies(assigns.query)
    default_total = totals[socket.assigns.default_currency] || 0
    others_totals = Map.drop(totals, [socket.assigns.default_currency])

    {:ok,
     socket
     |> assign(page_title: assigns.page_title)
     |> assign(count: Statistics.count(assigns.query))
     |> assign(chart_data: Statistics.get_amount_per_day(assigns.query))
     |> assign(default_total: default_total)
     |> assign(other_totals: others_totals)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="mb-4">
      <div class="is-flex is-justify-content-space-between">
        <div class="is-flex is-align-items-center">
          <h1>
            <%= @page_title %>
            <span class="subtitle is-5">
              ( <%= @count %> Found)
            </span>
          </h1>
        </div>
        <header
          class="card card-header is-clickable is-unselectable is-size-5"
          phx-click="change-summary-state"
          phx-target={@myself}
        >
          <div class="card-header-content m-3">
            <div class="card-header-title has-text-weight-bold p-0">
              <%= PageView.money_format(@default_total, @default_currency) %>
            </div>
            <%= for {currency, total} <- @other_totals do %>
              <div class="card-header-title has-text-weight-medium p-0">
                <%= PageView.money_format(total, currency) %>
              </div>
            <% end %>
          </div>
          <button class="card-header-icon pl-0" aria-label="more options">
            <span class="icon">
              <i class={"fas #{@summary_state.icon}"} aria-hidden="true"></i>
            </span>
          </button>
        </header>
      </div>

      <div id="summary-card" class={"card #{@summary_state.visibility}"}>
        <div class="card-content">
          <div class="content">
            <%= summary_chart(@chart_data) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("change-summary-state", _params, socket) do
    if socket.assigns.summary_state.visibility == "is-hidden" do
      {:noreply, assign(socket, :summary_state, set_summary(:opened))}
    else
      {:noreply, assign(socket, :summary_state, set_summary(:closed))}
    end
  end

  @spec summary_chart([tuple]) :: {:safe, [...]}
  defp summary_chart(invoices_data) do
    invoices_data
    |> Enum.map(fn {date, amount} -> {NaiveDateTime.new!(date, ~T[00:00:00]), amount} end)
    |> GraphicHelpers.line_plot(
      y_formatter: &PageView.money_format(&1, "USD", symbol: false, fractional_unit: false)
    )
  end

  @spec set_summary(:opened | :closed) :: map()
  defp set_summary(:opened), do: %{visibility: "is-block", icon: "fa-angle-up"}
  defp set_summary(:closed), do: %{visibility: "is-hidden", icon: "fa-angle-down"}
end

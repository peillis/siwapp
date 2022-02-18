defmodule SiwappWeb.IndexHeaderComponent do
  @moduledoc false
  use SiwappWeb, :live_component

  alias SiwappWeb.GraphicHelpers

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, summary_state: set_summary(:closed))}
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
            (<%= @count %> Found)
          </span>
        </h1>
      </div>
      <header
        class="card card-header is-clickable is-unselectable is-size-5"
        phx-click="change-summary-state" phx-target={@myself}
      >
        <div class="card-header-content m-3">
          <div class="card-header-title has-text-weight-bold p-0">
            <%= @totals.default %>
          </div>
          <%= for currency_total <- @totals.others do %>
            <div class="card-header-title has-text-weight-medium p-0">
              <%= currency_total %>
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
  defp summary_chart(invoices_data_for_a_month) do
    invoices_data_for_a_month
    |> Enum.map(fn {date, amount} -> {NaiveDateTime.new!(date, ~T[00:00:00]), amount} end)
    |> GraphicHelpers.line_plot()
  end

  @spec set_summary(:opened | :closed) :: map()
  defp set_summary(:opened), do: %{visibility: "is-block", icon: "fa-angle-up"}
  defp set_summary(:closed), do: %{visibility: "is-hidden", icon: "fa-angle-down"}

end

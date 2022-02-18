defmodule SiwappWeb.InvoicesLive.Index do
  @moduledoc false
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Search
  alias SiwappWeb.GraphicHelpers
  alias SiwappWeb.PageView

  @impl Phoenix.LiveView
  def mount(_params, _session, %{id: "home"} = socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:invoices, Invoices.list_past_due(0))
     |> assign(:checked, MapSet.new())}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:invoices, Invoices.scroll_listing(0))
     |> assign(:number_of_invoices, Invoices.count())
     |> assign(:checked, MapSet.new())
     |> assign(:summary_state, set_summary(:closed))
     |> assign(:chart_data, Invoices.Statistics.get_data_for_a_month())
     |> assign(:totals, total_per_currencies())
     |> assign(:page_title, "Invoices")
     |> assign(:checked, MapSet.new())}
  end

  @impl Phoenix.LiveView
  def handle_event("load-more", _, %{id: "home"} = socket) do
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

  def handle_event("load-more", _, socket) do
    %{
      page: page,
      invoices: invoices
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        invoices: invoices ++ Invoices.scroll_listing(page + 1),
        page: page + 1
      )
    }
  end

  def handle_event("click_checkbox", params, socket) do
    checked = update_checked(params, socket)

    {:noreply, assign(socket, checked: checked)}
  end

  def handle_event("redirect", %{"id" => id}, socket) do
    invoice = Invoices.get!(String.to_integer(id))

    if Invoices.status(invoice) == :paid do
      {:noreply, push_redirect(socket, to: Routes.page_path(socket, :show_invoice, id))}
    else
      {:noreply, push_redirect(socket, to: Routes.invoices_edit_path(socket, :edit, id))}
    end
  end

  def handle_event("search", params, socket) do
    invoices = Search.filters(Invoice, params["search_input"])

    {:noreply,
     socket
     |> assign(:invoices, invoices)
     |> assign(:number_of_invoices, length(invoices))
     |> assign(:chart_data, Invoices.Statistics.get_data_for_a_month(invoices))
     |> assign(:totals, total_per_currencies(invoices))}
  end

  def handle_event("change-summary-state", _params, socket) do
    if socket.assigns.summary_state.visibility == "is-hidden" do
      {:noreply, assign(socket, :summary_state, set_summary(:opened))}
    else
      {:noreply, assign(socket, :summary_state, set_summary(:closed))}
    end
  end

  @spec update_checked(map(), Phoenix.LiveView.Socket.t()) :: MapSet.t()
  defp update_checked(%{"id" => "0", "value" => "on"}, socket) do
    socket.assigns.invoices
    |> MapSet.new(& &1.id)
    |> MapSet.put(0)
  end

  defp update_checked(%{"id" => "0"}, _) do
    MapSet.new()
  end

  defp update_checked(%{"id" => id, "value" => "on"}, socket) do
    MapSet.put(socket.assigns.checked, String.to_integer(id))
  end

  defp update_checked(%{"id" => id}, socket) do
    socket.assigns.checked
    |> MapSet.delete(String.to_integer(id))
    |> MapSet.delete(0)
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

  @spec total_per_currencies([Invoice.t()]) :: map()
  defp total_per_currencies(invoices \\ Invoices.list()) do
    totals = Invoices.Statistics.get_accumulated_amount_per_currencies(invoices)
    default_currency = Siwapp.Settings.value(:currency)

    default_total = totals[default_currency]
    others_totals = Map.drop(totals, [default_currency])

    %{
      default: PageView.set_currency(default_total, default_currency),
      others:
        Enum.map(others_totals, fn {currency, amount} ->
          PageView.set_currency(amount, currency)
        end)
    }
  end
end

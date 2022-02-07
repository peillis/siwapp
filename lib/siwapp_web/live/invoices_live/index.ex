defmodule SiwappWeb.InvoicesLive.Index do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Invoices
  alias SiwappWeb.GraphicHelpers

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:invoices, Invoices.scroll_listing(0))
     |> assign(:checked, MapSet.new())
     |> assign(:summary_section, set_summary(:closed))
     |> assign(:page_title, "Invoices")}
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

  def handle_event("change-summary-state", _params, socket) do
    if socket.assigns.summary_section.state == "opened" do
      {:noreply, assign(socket, :summary_section, set_summary(:closed))}
    else
      {:noreply, assign(socket, :summary_section, set_summary(:opened))}
    end
  end

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

  defp summary_chart() do
    Invoices.Statistics.get_data()
    |> Enum.map(&GraphicHelpers.date_to_naive_type/1)
    |> GraphicHelpers.line_plot()
  end

  defp set_summary(:opened), do: %{state: "opened", visibility: "is-block", icon: "fa-angle-up"}
  defp set_summary(:closed), do: %{state: "closed", visibility: "is-hidden", icon: "fa-angle-down"}
end

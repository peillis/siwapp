defmodule SiwappWeb.InvoicesLive.Index do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:invoices, Invoices.list())
     |> assign(:checked, MapSet.new())}
  end

  def handle_event("click_checkbox", %{"id" => "0", "value" => "on"}, socket) do
    update_checked = add_all_ids(socket.assigns.invoices)

    {:noreply,
     assign(
       socket,
       checked: update_checked
     )}
  end

  def handle_event("click_checkbox", %{"id" => "0"}, socket) do
    {:noreply,
     assign(
       socket,
       checked: MapSet.new()
     )}
  end

  def handle_event("click_checkbox", %{"id" => id, "value" => "on"}, socket) do
    update_checked = MapSet.put(socket.assigns.checked, id)

    {:noreply,
     assign(
       socket,
       checked: update_checked
     )}
  end

  def handle_event("click_checkbox", %{"id" => id}, socket) do
    update_checked = MapSet.delete(socket.assigns.checked, id)

    if MapSet.size(update_checked) == 1 and MapSet.member?(update_checked, "0") do
      {:noreply,
       assign(
         socket,
         checked: MapSet.new()
       )}
    else
      {:noreply,
       assign(
         socket,
         checked: update_checked
       )}
    end
  end

  defp add_all_ids(invoices) do
    add_zero =
      MapSet.new()
      |> MapSet.put("0")

    invoices
    |> Enum.reduce(add_zero, fn invoice, mapset ->
      MapSet.put(mapset, Integer.to_string(invoice.id))
    end)
  end
end

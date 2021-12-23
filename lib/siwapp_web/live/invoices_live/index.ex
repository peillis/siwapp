defmodule SiwappWeb.InvoicesLive.Index do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:invoices, Invoices.list())
     |> assign(:checked, MapSet.new())}
  end

  def handle_event("show_buttons?", %{"id" => "0", "value" => "on"}, socket) do
    update_checked = add_all_ids(socket.assigns.checked, socket.assigns.invoices)

    {:noreply,
     assign(
       socket,
       checked: update_checked
     )}
  end

  def handle_event("show_buttons?", %{"id" => "0"}, socket) do
    update_checked = del_all_ids(socket.assigns.checked, socket.assigns.invoices)

    {:noreply,
     assign(
       socket,
       checked: update_checked
     )}
  end

  def handle_event("show_buttons?", %{"id" => id, "value" => "on"}, socket) do
    update_checked = MapSet.put(socket.assigns.checked, id)

    {:noreply,
     assign(
       socket,
       checked: update_checked
     )}
  end

  def handle_event("show_buttons?", %{"id" => id}, socket) do
    update_checked = MapSet.delete(socket.assigns.checked, id)

    if MapSet.size(update_checked) == 1 do
      update_checked = MapSet.delete(update_checked, "0")

      {:noreply,
       assign(
         socket,
         checked: update_checked
       )}
    else
      {:noreply,
       assign(
         socket,
         checked: update_checked
       )}
    end
  end

  defp add_all_ids(checked, invoices) do
    add_zero =
      checked
      |> MapSet.put("0")

    invoices
    |> Enum.reduce(add_zero, fn invoice, acc -> MapSet.put(acc, Integer.to_string(invoice.id)) end)
  end

  defp del_all_ids(checked, invoices) do
    del_zero =
      checked
      |> MapSet.delete("0")

    invoices
    |> Enum.reduce(del_zero, fn invoice, acc ->
      MapSet.delete(acc, Integer.to_string(invoice.id))
    end)
  end
end

defmodule SiwappWeb.InvoicesLive.Index do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:invoices, Invoices.list())
     |> assign(:checked, MapSet.new())}
  end

  def handle_event("click_checkbox", data, socket) do
    checked = update_checked(data, socket)

    {:noreply,
     assign(
       socket,
       checked: checked
     )}
  end

  defp update_checked(%{"id" => "0", "value" => "on"}, socket) do
    add_zero =
      MapSet.new()
      |> MapSet.put("0")

    socket.assigns.invoices
    |> Enum.reduce(add_zero, fn invoice, mapset ->
      MapSet.put(mapset, Integer.to_string(invoice.id))
    end)
  end

  defp update_checked(%{"id" => "0"}, _) do
    MapSet.new()
  end

  defp update_checked(%{"id" => id, "value" => "on"}, socket) do
    MapSet.put(socket.assigns.checked, id)
  end

  defp update_checked(%{"id" => id}, socket) do
    socket.assigns.checked
    |> MapSet.delete(id)
    |> MapSet.delete("0")
  end
end

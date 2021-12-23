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
    IO.inspect(checked)

    {:noreply,
     assign(
       socket,
       checked: checked
     )}
  end

  defp update_checked(%{"id" => "0", "value" => "on"}, socket) do
    socket.assigns.invoices
    |> MapSet.new(fn invoice -> invoice.id end)
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
end

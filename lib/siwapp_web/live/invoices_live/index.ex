defmodule SiwappWeb.InvoicesLive.Index do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:invoices, Invoices.list())
     |> assign(:checked, MapSet.new())}
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

    {:noreply,
     assign(
       socket,
       checked: update_checked
     )}
  end
end

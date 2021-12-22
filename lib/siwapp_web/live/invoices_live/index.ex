defmodule SiwappWeb.InvoicesLive.Index do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:invoices, Invoices.list())
     |> assign(:invisible_buttons, true)
     |> assign(:checked, %{})}
  end

  def handle_event("show_buttons", %{"id" => id, "value" => "on"}, socket) do
    update_checked = Map.put(socket.assigns.checked, id, true)

    {:noreply,
     assign(
       socket,
       invisible_buttons: false,
       checked: update_checked
     )}
  end

  def handle_event("show_buttons", %{"id" => id}, socket) do
    update_checked = Map.replace!(socket.assigns.checked, id, false)
    invisible_buttons = someone_checked?(update_checked)

    {:noreply,
     assign(
       socket,
       invisible_buttons: invisible_buttons,
       checked: update_checked
     )}
  end

  defp someone_checked?(checked) do
    checked
    |> Map.values()
    |> Enum.filter(fn val -> val == true end)
    |> Enum.empty?()
  end
end

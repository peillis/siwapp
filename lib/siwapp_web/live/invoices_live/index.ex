defmodule SiwappWeb.InvoicesLive.Index do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:invoices, Invoices.list())
     |> assign(:invisible, true)
     |> assign(:checked, nil)
     |> assign(:all, false)}
  end

  def handle_event("nav_render", %{"id" => id, "value" => "on"}, socket) do
    if is_nil(socket.assigns.checked) do
      updated_checked = %{id => true}

      {:noreply,
       assign(
         socket,
         invisible: false,
         checked: updated_checked,
         all: false
       )}
    else
      update_checked = Map.put(socket.assigns.checked, id, true)

      {:noreply,
       assign(
         socket,
         invisible: false,
         checked: update_checked,
         all: false
       )}
    end
  end

  def handle_event("nav_render", %{"id" => id}, socket) do
    update_checked = Map.replace!(socket.assigns.checked, id, false)
    invisible = someone_checked?(update_checked)

    {:noreply,
     assign(
       socket,
       invisible: invisible,
       checked: update_checked,
       all: false
     )}
  end

  defp someone_checked?(checked) do
    checked
    |> Map.values()
    |> Enum.filter(fn val -> val == true end)
    |> Enum.empty?()
  end
end

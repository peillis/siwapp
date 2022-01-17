defmodule SiwappWeb.InvoicesLive.TableComponent do
  @moduledoc false
  use SiwappWeb, :live_component
  alias Siwapp.Invoices

  def handle_event("click_checkbox", params, socket) do
    checked = update_checked(params, socket)

    {:noreply, assign(socket, checked: checked)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.invoices_edit_path(socket, :edit, id))}
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
end

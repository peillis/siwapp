defmodule SiwappWeb.RecurringInvoicesLive.Index do
  @moduledoc """
  This module manages the recurring_invoices LiveView events
  """
  use SiwappWeb, :live_view
  alias Siwapp.RecurringInvoices

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:recurring_invoices, RecurringInvoices.list())
     |> assign(:checked, MapSet.new())}
  end

  def handle_event("click_checkbox", params, socket) do
    checked = update_checked(params, socket)

    {:noreply, assign(socket, checked: checked)}
  end

  defp update_checked(%{"id" => "0", "value" => "on"}, socket) do
    socket.assigns.recurring_invoices
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

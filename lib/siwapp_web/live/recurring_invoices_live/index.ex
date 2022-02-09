defmodule SiwappWeb.RecurringInvoicesLive.Index do
  @moduledoc """
  This module manages the recurring_invoices LiveView events
  """
  use SiwappWeb, :live_view
  alias Siwapp.RecurringInvoices
  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Search

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(
       :recurring_invoices,
       RecurringInvoices.list(limit: 20, offset: 0, preload: [:series])
     )
     |> assign(:checked, MapSet.new())}
  end

  @impl Phoenix.LiveView
  def handle_event("load-more", _, socket) do
    %{
      page: page,
      recurring_invoices: recurring_invoices
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        recurring_invoices:
          recurring_invoices ++
            RecurringInvoices.list(limit: 20, offset: (page + 1) * 20, preload: [:series]),
        page: page + 1
      )
    }
  end

  def handle_event("click_checkbox", params, socket) do
    checked = update_checked(params, socket)

    {:noreply, assign(socket, checked: checked)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.recurring_invoices_edit_path(socket, :edit, id))}
  end

  def handle_event("search", params, socket) do
    values =
      params
      |> Enum.reject(fn {_key, val} -> val in ["", "Choose..."] end)

    recurring_invoices = Search.filters(RecurringInvoice, values)

    {:noreply, assign(socket, :recurring_invoices, recurring_invoices)}
  end

  @spec update_checked(map(), Phoenix.LiveView.Socket.t()) :: MapSet.t()
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

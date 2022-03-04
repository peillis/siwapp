defmodule SiwappWeb.RecurringInvoicesLive.Index do
  @moduledoc """
  This module manages the recurring_invoices LiveView events
  """
  use SiwappWeb, :live_view

  import SiwappWeb.PageView, only: [money_format: 3, money_format: 2]

  alias Siwapp.Invoices.Statistics
  alias Siwapp.RecurringInvoices
  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Searches

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    query = Searches.filters_query(RecurringInvoice, params)

    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:query, query)
     |> assign(
       :recurring_invoices,
       Searches.filters(query, preload: [:series])
     )
     |> assign(:checked, MapSet.new())
     |> assign(:page_title, "Recurring Invoices")}
  end

  @impl Phoenix.LiveView
  def handle_event("load-more", _, socket) do
    %{
      page: page,
      recurring_invoices: recurring_invoices,
      query: query
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        recurring_invoices:
          recurring_invoices ++
            Searches.filters(query, offset: (page + 1) * 20, preload: [:series]),
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

  def handle_event("generate_invoices", _, socket) do
    RecurringInvoices.generate_invoices()
    {:noreply, push_redirect(socket, to: Routes.invoices_index_path(socket, :index))}
  end

  def handle_event("delete", _params, socket) do
    socket.assigns.checked
    |> MapSet.to_list()
    |> List.delete(0)
    |> Enum.map(&RecurringInvoices.get!(&1, :preload))
    |> Enum.each(&RecurringInvoices.delete(&1))

    socket =
      socket
      |> put_flash(:info, "Recurring Invoices succesfully deleted")
      |> push_redirect(to: Routes.recurring_invoices_index_path(socket, :index))

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:search, params}, socket) do
    {:noreply,
     push_redirect(socket, to: Routes.recurring_invoices_index_path(socket, :index, params))}
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

defmodule SiwappWeb.InvoicesLive.Index do
  @moduledoc false
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Query
  alias Siwapp.Searches

  @impl Phoenix.LiveView
  def mount(%{"id" => customer_id}, _session, socket) do
    invoices =
      Invoices.list(
        filters: [customer_id: customer_id],
        preload: :series,
        limit: 20,
        offset: 0
      )

    name = Siwapp.Customers.get!(customer_id).name

    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:invoices, invoices)
     |> assign(:checked, MapSet.new())
     |> assign(:page_title, "Invoices for #{name}")
     |> assign(:query, Query.by(Invoice, :customer_id, customer_id))
     |> assign(:customer_id, customer_id)}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:invoices, Invoices.list(limit: 20, offset: 0, preload: [:series]))
     |> assign(:checked, MapSet.new())
     |> assign(:query, Invoice)
     |> assign(:page_title, "Invoices")}
  end

  @impl Phoenix.LiveView
  def handle_event("load-more", _, socket) do
    %{
      page: page,
      invoices: invoices,
      query: query
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        invoices:
          invoices ++ Searches.filters(query, offset: (page + 1) * 20, preload: [:series]),
        page: page + 1
      )
    }
  end

  def handle_event("click_checkbox", params, socket) do
    checked = update_checked(params, socket)

    {:noreply, assign(socket, checked: checked)}
  end

  def handle_event("redirect", %{"id" => id}, socket) do
    invoice = Invoices.get!(id)

    if Invoices.status(invoice) == :paid do
      {:noreply, push_redirect(socket, to: Routes.page_path(socket, :show_invoice, id))}
    else
      {:noreply, push_redirect(socket, to: Routes.invoices_edit_path(socket, :edit, id))}
    end
  end

  def handle_event("delete", _params, socket) do
    socket.assigns.checked
    |> MapSet.to_list()
    |> Enum.reject(&(&1 == 0))
    |> Enum.map(&Invoices.get!(&1, preload: [{:items, :taxes}]))
    |> Enum.each(&Invoices.delete(&1))

    socket =
      socket
      |> put_flash(:info, "Invoices succesfully deleted")
      |> push_redirect(to: Routes.invoices_index_path(socket, :index))

    {:noreply, socket}
  end

  def handle_event("send_email", _params, socket) do
    socket.assigns.checked
    |> MapSet.to_list()
    |> Enum.reject(&(&1 == 0))
    |> Enum.map(&Invoices.get!(&1, preload: [{:items, :taxes}, :series]))
    |> Enum.each(&Invoices.send_email(&1))

    socket =
      socket
      |> put_flash(:info, "Invoices sent by mail")
      |> push_redirect(to: Routes.invoices_index_path(socket, :index))

    {:noreply, socket}
  end

  def handle_event("duplicate", _params, socket) do
    socket.assigns.checked
    |> MapSet.to_list()
    |> Enum.map(&Invoices.get!(&1, preload: [{:items, :taxes}]))
    |> Enum.each(&Invoices.duplicate(&1))

    socket =
      socket
      |> put_flash(:info, "Invoices succesfully deleted")
      |> push_redirect(to: Routes.invoices_index_path(socket, :index))

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:search, params}, socket) do
    query = Searches.filters_query(Invoice, params)
    invoices = Searches.filters(query, preload: [:series])

    {:noreply,
     socket
     |> assign(:query, query)
     |> assign(:invoices, invoices)}
  end

  @spec download_url(MapSet.t()) :: binary
  def download_url(checked) do
    "invoices/download" <>
      (checked
       |> MapSet.to_list()
       |> Enum.reject(&(&1 == 0))
       |> Enum.reduce("", fn id, acc -> acc <> "/#{id}" end))
  end

  @spec update_checked(map(), Phoenix.LiveView.Socket.t()) :: MapSet.t()
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

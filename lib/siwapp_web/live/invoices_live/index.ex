defmodule SiwappWeb.InvoicesLive.Index do
  @moduledoc false
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Invoices.InvoiceQuery
  alias Siwapp.{Invoices, Search}

  @impl Phoenix.LiveView
  def mount(_params, _session, %{id: "home"} = socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(
       :invoices,
       Invoices.list(limit: 20, offset: 0, preload: [:series], filters: [with_status: :past_due])
     )
     |> assign(:checked, MapSet.new())}
  end

  def mount(%{"id" => id}, _session, socket) do
    customer_id = String.to_integer(id)

    invoices =
      Invoices.list(
        filters: [{:customer_id, customer_id}],
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
     |> assign(:query, InvoiceQuery.list_by_customer(customer_id))
     |> assign(:customer_id, customer_id)}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(:invoices, Invoices.list(limit: 20, offset: 0, preload: [:series]))
     |> assign(:checked, MapSet.new())
     |> assign(:query, Invoice)
     |> assign(:page_title, "Invoices")
     |> assign(:checked, MapSet.new())}
  end

  @impl Phoenix.LiveView
  def handle_event("load-more", _, %{id: "home"} = socket) do
    %{
      page: page,
      invoices: invoices
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        invoices:
          invoices ++
            Invoices.list(
              limit: 20,
              offset: (page + 1) * 20,
              preload: [:series],
              filters: [with_status: :past_due]
            ),
        page: page + 1
      )
    }
  end

  def handle_event("load-more", _, %{live_action: :customer} = socket) do
    %{
      page: page,
      invoices: invoices,
      customer_id: customer_id
    } = socket.assigns

    more_invoices =
      Invoices.list(
        filters: [{:customer_id, customer_id}],
        preload: :series,
        limit: 20,
        offset: (page + 1) * 20
      )

    {
      :noreply,
      assign(socket,
        invoices: invoices ++ more_invoices,
        page: page + 1
      )
    }
  end

  def handle_event("load-more", _, socket) do
    %{
      page: page,
      invoices: invoices
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        invoices:
          invoices ++ Invoices.list(limit: 20, offset: (page + 1) * 20, preload: [:series]),
        page: page + 1
      )
    }
  end

  def handle_event("click_checkbox", params, socket) do
    checked = update_checked(params, socket)

    {:noreply, assign(socket, checked: checked)}
  end

  def handle_event("redirect", %{"id" => id}, socket) do
    invoice = Invoices.get!(String.to_integer(id))

    if Invoices.status(invoice) == :paid do
      {:noreply, push_redirect(socket, to: Routes.page_path(socket, :show_invoice, id))}
    else
      {:noreply, push_redirect(socket, to: Routes.invoices_edit_path(socket, :edit, id))}
    end
  end

  def handle_event("change-summary-state", _params, socket) do
    if socket.assigns.summary_state.visibility == "is-hidden" do
      {:noreply, assign(socket, :summary_state, set_summary(:opened))}
    else
      {:noreply, assign(socket, :summary_state, set_summary(:closed))}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:search, params}, socket) do
    invoices = Search.filters(Invoice, params)

    {:noreply,
     socket
     |> assign(:invoices, invoices)}
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

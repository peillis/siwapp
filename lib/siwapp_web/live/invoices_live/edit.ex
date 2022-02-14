defmodule SiwappWeb.InvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias SiwappWeb.InvoicesLive.CustomerComponent
  alias SiwappWeb.ItemView

  alias Siwapp.Commons
  alias Siwapp.Invoices
  alias Siwapp.Invoices.{Invoice, Item}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:multiselect_options, Commons.list_taxes_for_multiselect())
     |> assign(:series, Commons.list_series())
     |> assign(:currency_options, Invoices.list_currencies())
     |> assign(:customer_suggestions, [])}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    new_invoice = %Invoice{items: [%Item{taxes: []}]}

    changeset =
      invoice
      |> Invoices.change()
      |> Invoices.number_assignment_when_legal()

    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, new_invoice)
    |> assign(
      :changeset,
      Invoices.change(new_invoice)
    )
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    invoice =
      Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series, :customer])

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, invoice.name)
    |> assign(:invoice, invoice)
    |> assign(:changeset, Invoices.change(invoice))
  end

  def handle_event("save", %{"invoice" => params}, socket) do
    result =
      case socket.assigns.live_action do
        :new -> Invoices.create(params)
        :edit -> Invoices.update(socket.assigns.invoice, params)
      end

    case result do
      {:ok, _invoice} ->
        socket =
          socket
          |> put_flash(:info, "Invoice successfully saved")
          |> push_redirect(to: Routes.invoices_index_path(socket, :index))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event(
        "validate",
        %{"invoice" => params, "_target" => ["invoice", "series_id"]},
        socket
      ) do
    changeset =
      socket.assigns.invoice
      |> Invoices.change(params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("validate", %{"invoice" => params}, socket) do
    changeset = Invoices.change(socket.assigns.invoice, params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add_item", _, socket) do
    changeset = ItemView.add_item(socket.assigns.changeset)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_item", %{"item-id" => item_id}, socket) do
    changeset = ItemView.remove_item(socket.assigns.changeset, String.to_integer(item_id))

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_info({:update_changeset, params}, socket) do
    changeset = Invoices.change(socket.assigns.invoice, params)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end

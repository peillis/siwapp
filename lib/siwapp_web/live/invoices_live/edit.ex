defmodule SiwappWeb.InvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias SiwappWeb.MetaAttributesComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Invoice")
    |> assign(:changeset, Invoices.change(%Invoice{}))
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))

    socket
    |> assign(:page_title, invoice.name)
    |> assign(:invoice, invoice)
    |> assign(:changeset, Invoices.change(invoice))
  end

  def handle_event("save", %{"invoice" => params, "meta" => meta}, socket) do
    params = MetaAttributesComponent.merge(params, meta)

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
end

defmodule SiwappWeb.InvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias SiwappWeb.InvoicesLive.CustomerComponent

  alias Siwapp.Commons
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Invoices.Payment

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:series, Commons.list_series())
     |> assign(:currency_options, Invoices.list_currencies())}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl Phoenix.LiveView
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

  def handle_event("validate", %{"invoice" => params}, socket) do
    changeset = Invoices.change(socket.assigns.invoice, params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("delete", _params, socket) do
    Invoices.delete(socket.assigns.invoice)

    socket =
      socket
      |> put_flash(:info, "Invoice succesfully deleted")
      |> push_redirect(to: Routes.invoices_index_path(socket, :index))

    {:noreply, socket}
  end

  def handle_event("add_payment", _, socket) do
    existing_payments = Map.get(socket.assigns.changeset.changes, :payments, [])
    currency = Ecto.Changeset.get_field(socket.assigns.changeset, :currency)

    payments = existing_payments ++ [Invoices.change_payment(%Payment{}, currency)]

    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :payments, payments)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_payment", %{"payment-id" => payment_index}, socket) do
    payments =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:payments)
      |> List.delete_at(String.to_integer(payment_index))

    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :payments, payments)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl Phoenix.LiveView
  def handle_info({:params_updated, params}, socket) do
    changeset = Invoices.change(socket.assigns.invoice, params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @spec apply_action(Phoenix.LiveView.Socket.t(), :new | :edit, map()) ::
          Phoenix.LiveView.Socket.t()
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, %Invoice{})
    |> assign(:changeset, Invoices.change(%Invoice{}, %{"items" => %{"0" => %{"taxes" => []}}}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    invoice = Invoices.get!(id, preload: [{:items, :taxes}, :payments, :series, :customer])

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, invoice.name)
    |> assign(:invoice, invoice)
    |> assign(:changeset, Invoices.change(invoice))
  end
end

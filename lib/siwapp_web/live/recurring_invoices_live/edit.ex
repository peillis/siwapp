defmodule SiwappWeb.RecurringInvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Commons
  alias Siwapp.Customers
  alias Siwapp.RecurringInvoices
  alias Siwapp.RecurringInvoices.RecurringInvoice

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:series, Commons.list_series())
     |> assign(:customer_suggestions, [])}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    new_recurring_invoice = %RecurringInvoice{items: [%{}]}

    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Recurring Invoice")
    |> assign(:recurring_invoice, new_recurring_invoice)
    |> assign(:changeset, RecurringInvoices.change(new_recurring_invoice))
    |> assign(:customer_name, "")
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    recurring_invoice = RecurringInvoices.get!(String.to_integer(id), :preload)

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, recurring_invoice.name)
    |> assign(:recurring_invoice, recurring_invoice)
    |> assign(:changeset, RecurringInvoices.change(recurring_invoice))
    |> assign(:customer_name, recurring_invoice.name)
  end

  def handle_event("save", %{"recurring_invoice" => params}, socket) do
    result =
      case socket.assigns.live_action do
        :new -> RecurringInvoices.create(params)
        :edit -> RecurringInvoices.update(socket.assigns.recurring_invoice, params)
      end

    case result do
      {:ok, _recurring_invoice} ->
        socket =
          socket
          |> put_flash(:info, "Recurring Invoice successfully saved")
          |> push_redirect(to: Routes.recurring_invoices_index_path(socket, :index))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event(
        "validate",
        %{"_target" => ["recurring_invoice", "name"], "recurring_invoice" => params},
        socket
      ) do
    customer_name_input = Map.get(params, "name")

    {:noreply,
     socket
     |> assign(:customer_suggestions, Customers.list_by_name_input(customer_name_input))
     |> assign(:customer_name, customer_name_input)}
  end

  def handle_event("validate", %{"recurring_invoice" => params}, socket) do
    changeset =
      socket.assigns.recurring_invoice
      |> RecurringInvoices.change(params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("pick_customer", %{"id" => customer_id}, socket) do
    customer_params =
      Customers.get(customer_id)
      |> Map.take([
        :name,
        :identification,
        :contact_person,
        :email,
        :invoicing_address,
        :shipping_address
      ])

    changeset =
      socket.assigns.recurring_invoice
      |> RecurringInvoices.change(customer_params)

    {:noreply,
     socket
     |> assign(:customer_suggestions, [])
     |> assign(:customer_name, customer_params.name)
     |> assign(:changeset, changeset)}
  end
end

defmodule SiwappWeb.CustomerLive.Edit do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias Siwapp.Schema.Customer

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    customer = Customer.changeset(%Customer{}, %{})

    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, customer)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    customer = Invoices.get_customer!(String.to_integer(id))

    socket
    |> assign(:page_title, customer.name)
    |> assign(:customer, customer)
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    customer_params
    |> Invoices.create_customer()

    {:noreply, socket}
  end
end

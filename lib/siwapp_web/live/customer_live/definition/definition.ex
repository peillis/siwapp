defmodule SiwappWeb.CustomerLive.Definition do
  use SiwappWeb, :live_view
  #alias Siwapp.Schema.Customer
  alias Siwapp.Invoices

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    SiwappWeb.CustomerView.render("definition.html", assigns)
  end

  def handle_params(params, url, socket) do
    IO.inspect "params"
    IO.inspect params
    IO.inspect "url"
    IO.inspect url
    IO.inspect "socket"
    IO.inspect socket
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    customer = Invoices.create_customer_void()
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, customer)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    customer = Invoices.get_customer!(id)
    socket
    |> assign(:page_title, customer.name )
    |> assign(:customer, customer)
  end

  def handle_event("save", params = %{ "customer" => customer }, socket) do
    IO.inspect "customer"
    IO.inspect customer
    IO.inspect "socket"
    IO.inspect socket
    IO.inspect "assigns"
    IO.inspect socket.assigns
    IO.inspect "params"
    IO.inspect params
    {:noreply, socket}
  end

end

defmodule SiwappWeb.CustomerLive.New do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias Siwapp.Schema.Customer

  def mount(params, session, socket) do
    changeset = Customer.changeset_void(%Customer{}, %{})
    IO.inspect changeset
    {:ok, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", params = %{ "customer" => customer }, socket) do
    IO.inspect "customer"
    IO.inspect customer
    IO.inspect "socket"
    IO.inspect socket
    IO.inspect "assigns"
    IO.inspect socket.assigns
    {:noreply, socket}
  end

end

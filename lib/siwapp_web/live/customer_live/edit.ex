defmodule SiwappWeb.CustomerLive.Edit do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices
  alias Siwapp.Schema.Customer

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    customer = Customer.changeset(%Customer{}, %{})
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, customer)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    customer = Invoices.get_customer!( String.to_integer(id))
    socket
    |> assign(:page_title, customer.name)
    |> assign(:customer, customer)
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    customer_params
    |> customer_params_active_value()
    |> customer_params_to_attrs()
    |> Invoices.create_customer()
    {:noreply, socket}
  end

  defp customer_params_active_value(customer_params) do
    %{ customer_params | "active" => customer_params["active"] |> String.to_existing_atom() }
  end

  defp customer_params_to_attrs(customer_params) do
    for {key, val} <- customer_params, into: %{}, do: {String.to_atom(key), val}
  end


end

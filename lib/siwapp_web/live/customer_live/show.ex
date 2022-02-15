defmodule SiwappWeb.CustomerLive.Show do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Customers

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= live_render(@socket, SiwappWeb.InvoicesLive.Index,
      id: "show_invoices",
      session: %{"customer_id" => @customer.id, "name" => @customer.name}
    ) %>
    """
  end

  def handle_params(%{"id" => customer_id}, _url, socket) do
    {:noreply, assign(socket, :customer, Customers.get(customer_id))}
  end
end

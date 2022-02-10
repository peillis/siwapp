defmodule SiwappWeb.CustomerLive.Show do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Customers

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :show, %{ "id" => customer_id }) do
    socket
    |> assign(:customer, Customers.get(customer_id))
  end
end

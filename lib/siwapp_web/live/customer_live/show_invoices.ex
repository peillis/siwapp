defmodule SiwappWeb.CustomersLive.ShowInvoices do
  use SiwappWeb, :live_view

  alias Siwapp.Customers

  def mount(_params, session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end
  
  def apply_action(socket, :show, %{"id" => id}) do
    changeset = Customers.get!(String.to_integer(id)) |> Customers.change()
    page_title = "Invoices for " <> changeset.data.name
    socket
    |> assign(:page_title, page_title)
    |> assign(:changeset, changeset)
  end
end

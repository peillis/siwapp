defmodule SiwappWeb.CustomerLive.Edit do
  use SiwappWeb, :live_view

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:changeset, Customers.change(%Customer{}))
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    customer = Customers.get!(String.to_integer(id))

    socket
    |> assign(:page_title, customer.name)
    |> assign(:changeset, Customers.change(customer))
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    case Customers.create(customer_params) do
      {:ok, _customer} ->
        socket =
          socket
          |> put_flash(:info, "Customer was successfully created")
          |> push_redirect(to: "/customers/new")
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

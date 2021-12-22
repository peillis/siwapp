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
    |> assign(:customer, customer)
    |> assign(:changeset, Customers.change(customer))
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    result =
      case socket.assigns.live_action do
        :new -> Customers.create(customer_params)
        :edit -> Customers.update(socket.assigns.customer, customer_params)
      end

    case result do
      {:ok, _customer} ->
        socket =
          socket
          |> put_flash(:info, "Customer successfully saved")
          |> push_redirect(to: "/customers/new")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({:remove_meta, key}, socket) do
    customer = socket.assigns.customer
    new_meta_attributes = Map.delete(customer.meta_attributes, key)
    customer = Map.put(customer, :meta_attributes, new_meta_attributes)

    changeset = Customers.change(customer)
    #changeset = socket.assigns.changeset
    #new_meta_attributes = Map.delete(changeset.data.meta_attributes, key)
    #data = Map.put(changeset.data, :meta_attributes, new_meta_attributes)
    #new_changeset = Map.put(changeset, :data, data)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end

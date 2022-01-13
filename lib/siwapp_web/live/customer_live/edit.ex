defmodule SiwappWeb.CustomerLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer
  alias SiwappWeb.MetaAttributesComponent

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

  def handle_event("validate", %{"customer" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Customers.change(params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"customer" => params, "meta" => meta}, socket) do
    params = MetaAttributesComponent.merge(params, meta)

    result =
      case socket.assigns.live_action do
        :new -> Customers.create(params)
        :edit -> Customers.update(socket.assigns.customer, params)
      end

    case result do
      {:ok, _customer} ->
        socket =
          socket
          |> put_flash(:info, "Customer successfully saved")
          |> push_redirect(to: Routes.customer_index_path(socket, :index))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    result = Customers.delete(socket.assigns.customer)

    case result do
      {:ok, _customer} ->
        socket =
          socket
          |> put_flash(:info, "Customer succesfully deleted")
          |> push_redirect(to: Routes.customer_index_path(socket, :index))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("copy", _params, socket) do
    invoicing_address =
      Map.get(
        socket.assigns.changeset.changes,
        :invoicing_address,
        socket.assigns.changeset.data.invoicing_address
      )

    changeset =
      socket.assigns.changeset
      |> Map.put(:changes, %{shipping_address: invoicing_address})

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("active", _params, socket) do
    new_active =
      !Map.get(socket.assigns.changeset.changes, :active, socket.assigns.changeset.data.active)

    changeset =
      socket.assigns.changeset
      |> Map.put(:changes, %{active: new_active})

    {:noreply, assign(socket, changeset: changeset)}
  end
end

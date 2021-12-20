defmodule SiwappWeb.CustomerLive.Edit do
  use SiwappWeb, :live_view

  import Ecto.Changeset

  alias Siwapp.Customers
  alias Siwapp.Commons

  def mount(_params, session, socket) do
    customer = get_customer(session)

    changeset =
      Customers.change(customer)
      |> put_embed(:meta_attributes, customer.meta_attributes)

    assigns = [
      changeset: changeset,
      customer: customer
    ]

    socket = assign(socket, assigns)
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
  end

  def apply_action(socket, :edit, _) do
    socket
    |> assign(:page_title, socket.assigns.customer.name)
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    case Customers.create(customer_params) do
      {:ok, created_customer} ->
        IO.inspect("created_customer")
        IO.inspect(created_customer)

        {:noreply,
         socket
         |> put_flash(:info, "Customer was successfully created")
         |> redirect(to: Routes.customer_index_path(socket, :index))}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"customer" => customer_params}, socket) do
    changeset =
      socket.assigns.customer
      |> Customers.change(customer_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add-meta-attribute", _params, socket) do
    existing_meta_attributes =
      Map.get(
        socket.assigns.changeset.changes,
        :meta_attributes,
        socket.assigns.customer.meta_attributes
      )

    meta_attributes =
      existing_meta_attributes
      |> Enum.concat([
        Commons.create_meta_attribute()
      ])

    changeset =
      socket.assigns.changeset
      |> put_embed(:meta_attributes, meta_attributes)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-meta-attribute", %{"remove" => remove_id}, socket) do
    meta_attributes =
      socket.assigns.changeset.changes.meta_attributes
      |> Enum.reject(fn %{data: meta_attributes} -> meta_attributes.temp_id == remove_id end)

    changeset =
      socket.assigns.changeset
      |> put_embed(:meta_attributes, meta_attributes)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("back", _params, socket) do
    {:noreply, redirect(socket, to: Routes.customer_index_path(socket, :index))}
  end

  defp get_customer(%{"id" => id} = _customer_params) do
    Customers.get!(id)
  end

  defp get_customer(_customer_params) do
    Customers.new()
    |> Map.put(:meta_attributes, [Commons.new_meta_attribute()])

    # %Customer{meta_attributes: []}
  end
end

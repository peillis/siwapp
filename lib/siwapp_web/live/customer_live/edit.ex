defmodule SiwappWeb.CustomerLive.Edit do
  use SiwappWeb, :live_view

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer
  alias Siwapp.MetaAttributes
  alias Siwapp.MetaAttributes.MetaAttribute

  def mount(_params, %{ "_csrf_token" => csrf_token } = session, socket) do
    IO.inspect "I'm in mount"
    customer = get_customer(session)
    changeset = 
      Customers.change(customer)
      |> Ecto.Changeset.put_embed(:meta_attribute, customer.meta_attribute)
    assigns = 
      [
        csrf_token: csrf_token,
        changeset: changeset,
        customer: customer
      ]
    socket = assign(socket, assigns)
    IO.inspect "socket"
    IO.inspect socket
    {:ok, socket}
  end


  def handle_params(params, _url, socket) do
    IO.inspect "I'm in handle_params"
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
<<<<<<< HEAD
    IO.inspect "I'm in apply_action new"
    socket
    |> assign(:page_title, "New Customer")
  end

  def apply_action(socket, :edit, _) do
    IO.inspect "I'm in apply_action edit"
    socket
    |> assign(:page_title, socket.assigns.customer.name)
=======
    changeset = Customer.changeset(%Customer{}, %{})

    socket
    |> assign(:page_title, "New Customer")
    |> assign(:changeset, changeset)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    changeset = Invoices.get_customer!(String.to_integer(id))

    socket
    |> assign(:page_title, changeset.name)
    |> assign(:changeset, changeset)
>>>>>>> d2d32bfecdcd37e6ffc018a4e2705a58a2fd7d5d
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    {:ok, created_customer} = 
      customer_params
      |> Customers.create()
    IO.inspect "created_customer"
    IO.inspect created_customer
    {:noreply, socket}
  end

<<<<<<< HEAD

  def handle_event("validate", %{ "customer" => customer_params }, socket) do
    IO.inspect "I'm in handle_event validate"
    changeset = 
      socket.assigns.customer
      |> Customer.changeset(customer_params)
      |> Map.put(:action, :insert)
    {:noreply, assign(socket, changeset: changeset)}
  end
  
  def handle_event("add-meta-attribute", _params, socket) do
    IO.inspect "I'm in handle_event add-meta_attribute"
    existing_meta_attributes = Map.get(socket.assigns.changeset.changes, :meta_attribute, socket.assigns.customer.meta_attribute)
    meta_attributes =
      existing_meta_attributes
      |> Enum.concat([ 
        MetaAttributes.change( %MetaAttribute{ temp_id: get_temp_id()}) 
      ])
    changeset = socket.assigns.changeset
                |> Ecto.Changeset.put_embed(:meta_attribute, meta_attributes)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-meta-attribute", %{ "remove" => remove_id }, socket) do
    meta_attributes =
      socket.assigns.changeset.changes.meta_attribute
      |> Enum.reject(fn %{ data: meta_attribute } -> meta_attribute.temp_id == remove_id end)
    changeset = 
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:meta_attribute, meta_attributes)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def get_customer(%{"id" => id}= _customer_params) do 
    IO.inspect ("I'm in get_customer(id)") 
    Customers.get!(id)
  end

  def get_customer(_customer_params) do 
    IO.inspect "I'm in get_customer(_)" 
    %Customer{meta_attribute: []}
  end

  defp get_temp_id do 
    IO.inspect "I'm in get_temp_id"
    :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)
  end
=======
  def handle_event("add-meta-attribute", _, socket) do
    existing_meta_attributes = Map.get(socket.assigns.changeset.changes, :meta_attributes, socket.assigns.changeset.meta_attributes)
    meta_attributes =
      existing_meta_attributes
      |> Enum.concat([ Invoices.change_meta_attribute( %MetaAttributes{ temp_id: get_temp_id() } ) ])

    changeset = socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:meta_attributes, meta_attributes)
    {:noreply, assign(socket, changeset: changeset)}
  end
  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)
>>>>>>> d2d32bfecdcd37e6ffc018a4e2705a58a2fd7d5d


end

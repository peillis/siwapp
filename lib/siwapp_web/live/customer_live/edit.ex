defmodule SiwappWeb.CustomerLive.Edit do
  use SiwappWeb, :live_view

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices
  alias Siwapp.Schema.MetaAttributes

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    changeset = Customer.changeset(%Customer{}, %{})

    socket
    |> assign(:page_title, "New Customer")
    |> assign(:changeset, changeset)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    customer = Customers.get!(String.to_integer(id))
    socket
    |> assign(:page_title, changeset.name)
    |> assign(:changeset, changeset)
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    customer_params
    |> Customers.create()

    {:noreply, socket}
  end

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


end

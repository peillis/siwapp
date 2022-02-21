defmodule SiwappWeb.CustomerLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"customer" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Customers.change(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"customer" => params}, socket) do
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
    Customers.delete(socket.assigns.customer)

    socket =
      socket
      |> put_flash(:info, "Customer succesfully deleted")
      |> push_redirect(to: Routes.customer_index_path(socket, :index))

    {:noreply, socket}
  end

  def handle_event("copy", _params, socket) do
    invoicing_address =
      Map.get(
        socket.assigns.changeset.changes,
        :invoicing_address,
        socket.assigns.changeset.data.invoicing_address
      )

    changeset =
      Map.put(socket.assigns.changeset, :changes, %{shipping_address: invoicing_address})

    {:noreply, assign(socket, changeset: changeset)}
  end

  @spec apply_action(Phoenix.LiveView.Socket.t(), :new | :edit, map()) ::
          Phoenix.LiveView.Socket.t()
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:changeset, Customers.change(%Customer{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    customer = Customers.get!(String.to_integer(id))

    socket
    |> assign(:page_title, customer.name)
    |> assign(:customer, customer)
    |> assign(:changeset, Customers.change(customer))
  end
end

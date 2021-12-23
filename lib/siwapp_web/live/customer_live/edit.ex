defmodule SiwappWeb.CustomersLive.Edit do
  use SiwappWeb, :live_view

  import SiwappWeb.HelpersLive

  alias Siwapp.Customers

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    changeset = Customers.new() |> Customers.change()

    socket
    |> assign(:page_title, "New Customer")
    |> assign(:changeset, changeset)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    changeset = Customers.get!(String.to_integer(id)) |> Customers.change()

    socket
    |> assign(:page_title, changeset.data.name)
    |> assign(:changeset, changeset)
  end

  def handle_event("save", %{"customer" => customer_params}, socket)
      when socket.assigns.live_action == :new do
    case Customers.create(customer_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Customer was successfully created")
         |> redirect_to_index()}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, display_errors(changeset))}
    end
  end

  def handle_event("save", %{"customer" => customer_params}, socket)
      when socket.assigns.live_action == :edit do
    case Customers.update(socket.assigns.changeset.data, customer_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Customer was successfully updated")
         |> redirect_to_index()}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, display_errors(changeset))}
    end
  end

  def handle_event("back", _, socket) do
    {:noreply, redirect_to_index(socket)}
  end

  def handle_event("delete", _, socket) do
    Customers.delete(socket.assigns.changeset.data)
    {:noreply, redirect_to_index(socket)}
  end
end

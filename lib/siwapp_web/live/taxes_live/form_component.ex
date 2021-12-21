defmodule SiwappWeb.TaxesLive.FormComponent do
  use SiwappWeb, :live_component

  alias Siwapp.Commons

  @impl true
  def update(%{tax: tax} = assigns, socket) do
    changeset = Commons.change_tax(tax)

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"tax" => tax_params}, socket) do
    changeset =
      socket.assigns.tax
      |> Commons.change_tax(tax_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"tax" => tax_params}, socket) do
    save_tax(socket, socket.assigns.action, tax_params)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    tax = Commons.get_tax!(id)
    {:ok, _taxes} = Commons.delete_tax(tax)

    {:noreply,
     socket
     |> put_flash(:info, "Tax was successfully destroyed.")
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp save_tax(socket, :edit, tax_params) do
    case Commons.update_tax(socket.assigns.tax, tax_params) do
      {:ok, _tax} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tax was successfully updated")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_tax(socket, :new, tax_params) do
    case Commons.create_tax(tax_params) do
      {:ok, _tax} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tax was successfully created")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

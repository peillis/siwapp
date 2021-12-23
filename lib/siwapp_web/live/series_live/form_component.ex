defmodule SiwappWeb.SeriesLive.FormComponent do
  use SiwappWeb, :live_component

  alias Siwapp.Commons

  @impl true
  def update(%{series: series} = assigns, socket) do

    changeset = Commons.change_series(series)

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"series" => series_params}, socket) do
    changeset =
      socket.assigns.series
      |> Commons.change_series(series_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"series" => series_params}, socket) do
    save_series(socket, socket.assigns.action, series_params)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    series = Commons.get_series(id)

    case  Commons.delete_series(series) do
      {:ok, _series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series was successfully destroyed.")
         |> push_redirect(to: socket.assigns.return_to)}
      {:error, _msg} ->
        {:noreply,
         socket
         |> put_flash(:error, "You can't delete the default series.")}
    end

  end

  defp save_series(socket, :edit, series_params) do
    case Commons.update_series(socket.assigns.series, series_params) do
      {:ok, _series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series was successfully updated")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_series(socket, :new, series_params) do
    case Commons.create_series(series_params) do
      {:ok, _series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series was successfully created")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

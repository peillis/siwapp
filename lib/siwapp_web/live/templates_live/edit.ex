defmodule SiwappWeb.TemplatesLive.Edit do
  use SiwappWeb, :live_view

  alias Siwapp.Templates
  alias Siwapp.Templates.Template

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Template")
    |> assign(:changeset, Templates.change(%Template{}))
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    template = Templates.get(id)

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, template.name)
    |> assign(:template, template)
    |> assign(:changeset, Templates.change(template))
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

    case Commons.delete_series(series) do
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

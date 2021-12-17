defmodule SiwappWeb.SeriesLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Settings
  alias Siwapp.Schema.Series

  @impl true
  def mount(_params, _session, socket) do
    series_list = Settings.list_series()
    {:ok, assign(socket, series_list: series_list)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("defaultClicked", %{"series_id" => series_id}, socket) do
    Settings.set_default_series(series_id)
    series_list = Settings.list_series()

    {:noreply, assign(socket, series_list: series_list)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    series = Settings.get_series(id)
    {:ok, _series} = Settings.delete_series(series)

    {:noreply,
     socket
     |> put_flash(:info, "Series was successfully destroyed.")
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    series = Settings.get_series(id)

    socket
    |> assign(:page_title, series.name)
    |> assign(:series, series)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Series")
    |> assign(:series, %Series{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "SERIES")
    |> assign(:series, nil)
  end
end

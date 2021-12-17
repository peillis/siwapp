defmodule SiwappWeb.SeriesLive do
  use SiwappWeb, :live_view

  alias Siwapp.Settings

  def mount(_params, _session, socket) do
    series = Settings.list_series()
    {:ok, assign(socket, series: series)}
  end

  def handle_event("defaultClicked", %{"series_id" => series_id}, socket) do
    Settings.set_default_series(String.to_integer(series_id))
    series = Settings.list_series()

    {:noreply, assign(socket, series: series)}
  end
end

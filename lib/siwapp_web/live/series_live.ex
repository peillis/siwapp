defmodule SiwappWeb.SeriesLive do
  use SiwappWeb, :live_view

  alias Siwapp.Settings
  alias Siwapp.Schema.Series

  def mount(_params, _session, socket) do
    series = Settings.list_series()
    {:ok, assign(socket, series: series)}
  end
end

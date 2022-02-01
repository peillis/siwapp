defmodule SiwappWeb.SearchLive.Index do
  @moduledoc false
  use Phoenix.LiveView, layout: {SiwappWeb.LayoutView, "search_live.html"}
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule SiwappWeb.SearchLive.Index do
  use Phoenix.LiveView, layout: {SiwappWeb.LayoutView, "search_live.html"}
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def toogle() do
    JS.toggle(to: "#search-menu")
  end
end

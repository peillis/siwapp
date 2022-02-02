defmodule SiwappWeb.SearchLive.Index do
  @moduledoc false
  use Phoenix.LiveView, layout: {SiwappWeb.LayoutView, "search_live.html"}
  alias Phoenix.LiveView.JS

  def mount(_params, session, socket) do
    {:ok, assign(socket, :path, session["path"])}
  end
end

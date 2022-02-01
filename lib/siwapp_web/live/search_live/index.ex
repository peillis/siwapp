defmodule SiwappWeb.SearchLive.Index do
  @moduledoc false
  use Phoenix.LiveView, layout: {SiwappWeb.LayoutView, "search_live.html"}
  alias SiwappWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.JS

  def mount(_params, session, socket) do
    {:ok, assign(socket, :path, session["path"])}
  end

  def handle_event("search_value", %{"value" => value}, socket) do
    {:noreply, assign(socket, :value, value)}
  end

  def handle_event("search", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.invoices_index_path(socket, :index, value: socket.assigns[:value]))}
  end
end

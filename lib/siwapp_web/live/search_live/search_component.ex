defmodule SiwappWeb.SearchLive.SearchComponent do
  @moduledoc false
  use SiwappWeb, :live_component
  alias Phoenix.LiveView.JS
  alias Siwapp.{Commons, Customers}

  def update(%{component: component}, socket) do
    socket =
      socket
      |> assign(:customers_names, Customers.list_names())
      |> assign(:series_names, Commons.list_series_names())
      |> assign(:component, component)

    {:ok, socket}
  end
end

defmodule SiwappWeb.SearchLive.SearchComponent do
  @moduledoc false
  use SiwappWeb, :live_component
  alias Phoenix.LiveView.JS
  alias Siwapp.{Commons,Customers}

  def update(%{component: component}, socket) do
    socket =
      socket
      |> assign(:customers, Customers.list())
      |> assign(:series, Commons.list_series)
      |> assign(:component, component)

    {:ok, socket}
  end
end

defmodule SiwappWeb.SearchLive.SearchComponent do
  @moduledoc false
  use SiwappWeb, :live_component
  alias Phoenix.LiveView.JS
  alias Siwapp.{Commons, Customers}

  def update(%{component: component}, socket) do
    socket =
      socket
      |> assign(:customers_name, Customers.get_customers_name())
      |> assign(:series_name, Commons.get_series_name())
      |> assign(:component, component)

    {:ok, socket}
  end
end

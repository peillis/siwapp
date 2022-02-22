defmodule SiwappWeb.SearchLive.SearchComponent do
  @moduledoc false
  use SiwappWeb, :live_component
  alias Phoenix.LiveView.JS
  alias Siwapp.Commons
  alias Siwapp.Customers.Customer
  alias Siwapp.Search

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:series_names, Commons.list_series_names())
      |> assign(:filters, assigns.filters)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_customers", %{"_target" => ["name"], "name" => value}, socket) do
    if value == "" do
      send_update(SiwappWeb.SearchLive.CustomersInputComponent, id: "customers")

      {:noreply, socket}
    else
      customers_names = Search.get_customers_names(Customer, value, 0)

      send_update(SiwappWeb.SearchLive.CustomersInputComponent,
        id: "customers",
        customers_names: customers_names,
        value: value
      )

      {:noreply, socket}
    end
  end

  def handle_event("search_customers", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    params = Enum.reject(params, fn {_key, val} -> val in ["", "Choose..."] end)

    send(self(), {:search, params})

    {:noreply, socket}
  end
end

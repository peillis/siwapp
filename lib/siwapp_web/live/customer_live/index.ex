defmodule SiwappWeb.CustomerLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Customers

  def mount(_params, _session, socket) do
    {:ok, assign(socket, customers: Customers.list(), page_title: "Customers")}
  end
end

defmodule SiwappWeb.NewCustomerLive do
  use SiwappWeb, :live_view

  def mount(_params, _session, socket) do
    changeset = Siwapp.Schema.Customers.changeset(%Siwapp.Schema.Customers{}, %{})
    {:ok, assign(socket, :changeset, changeset)}
  end
end

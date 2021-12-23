defmodule SiwappWeb.CustomerLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Customers

  def mount(_params, _session, socket) do
    {:ok, assign(socket, customers: Customers.list(), page_title: "Customers")}
  end

  def path_edit_customer(id), do: "/customers/" <> to_string(id) <> "/edit"

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.customer_edit_path(socket, :edit, id))}
  end
end

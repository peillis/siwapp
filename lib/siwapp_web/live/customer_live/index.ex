defmodule SiwappWeb.CustomersLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Customers

  def mount(_params, _session, socket) do
    {:ok, assign(socket, customers: Customers.list(), page_title: "Customers")}
  end

  def handle_event("see-invoices", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.customers_show_invoices_path(socket, :show, id))}
  end

  def handle_event("new", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.customers_edit_path(socket, :new))}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.customers_edit_path(socket, :edit, id))}
  end
end

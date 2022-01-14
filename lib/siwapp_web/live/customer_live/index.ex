defmodule SiwappWeb.CustomerLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Customers

  @moduledoc """

  This module manages the customer index view
  """

  def mount(_params, _session, socket) do
    {:ok, assign(socket, customers: Customers.list(), page_title: "Customers")}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.customer_edit_path(socket, :edit, id))}
  end
end

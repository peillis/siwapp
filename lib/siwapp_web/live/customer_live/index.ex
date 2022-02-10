defmodule SiwappWeb.CustomerLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Customers
  alias SiwappWeb.PageView

  @moduledoc """

  This module manages the customer index view
  """

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(customers: Customers.scroll_listing(0))
     |> assign(page_title: "Customers")}
  end

  def handle_event("load-more", _, socket) do
    %{
      page: page,
      customers: customers
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        customers: customers ++ Customers.scroll_listing(page + 1),
        page: page + 1
      )
    }
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.customer_edit_path(socket, :edit, id))}
  end

  def money(customer_id, type) do
    case Customers.money(customer_id, type) do
      {amount, nil} -> amount
      {amount, currency} -> PageView.set_currency(amount, currency)
    end
  end
end

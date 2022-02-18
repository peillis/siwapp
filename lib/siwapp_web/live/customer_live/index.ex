defmodule SiwappWeb.CustomerLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Customers.Customer
  alias Siwapp.{Customers, Search}
  import SiwappWeb.PageView

  @moduledoc """

  This module manages the customer index view
  """

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(customers: Customers.list_index(20, 0))
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
        customers: customers ++ Customers.list_index(20, (page + 1) * 20),
        page: page + 1
      )
    }
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.customer_edit_path(socket, :edit, id))}
  end

  def handle_event("search", params, socket) do
    customers = Search.filters(Customer, params["search_input"])
    {:noreply, assign(socket, :customers, customers)}
  end

  @spec due(integer, integer) :: integer
  defp due(total, paid), do: total - paid

  @spec set_currency([] | [String.t()]) :: atom
  defp set_currency([currency]), do: String.to_atom(currency)
  defp set_currency(_list), do: nil
end

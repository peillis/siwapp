defmodule SiwappWeb.CustomerLive.Index do
  @moduledoc """

  This module manages the customer index view
  """

  use SiwappWeb, :live_view

  import SiwappWeb.PageView

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer
  alias Siwapp.Search

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page, 0)
     |> assign(customers: Customers.list_with_assoc_invoice_fields(20, 0))
     |> assign(page_title: "Customers")}
  end

  @impl Phoenix.LiveView
  def handle_event("load-more", _, socket) do
    %{
      page: page,
      customers: customers
    } = socket.assigns

    {
      :noreply,
      assign(socket,
        customers: customers ++ Customers.list_with_assoc_invoice_fields(20, (page + 1) * 20),
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

  @spec set_currency([] | [String.t()]) :: binary
  defp set_currency([]), do: "USD"
  defp set_currency(currencies), do: List.first(currencies)

  @spec symbol_option([] | [String.t()]) :: [{:symbol, true}] | [{:symbol, false}]
  defp symbol_option([_currency]), do: [{:symbol, true}]
  defp symbol_option(_currencies), do: [{:symbol, false}]
end

defmodule SiwappWeb.RecurringInvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Commons
  alias Siwapp.RecurringInvoices
  alias Siwapp.RecurringInvoices.RecurringInvoice

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:series, Commons.list_series())
     |> assign(:customer_suggestions, [])}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    new_recurring_invoice = %RecurringInvoice{}

    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Recurring Invoice")
    |> assign(:recurring_invoice, new_recurring_invoice)
    |> assign(:items, [%{}])
    |> assign(:changeset, RecurringInvoices.change(new_recurring_invoice))
    |> assign(:customer_name, "")
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    recurring_invoice = RecurringInvoices.get!(String.to_integer(id), :preload)

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, recurring_invoice.name)
    |> assign(:recurring_invoice, recurring_invoice)
    |> assign(:items, recurring_invoice.items)
    |> assign(:changeset, RecurringInvoices.change(recurring_invoice))
    |> assign(:customer_name, recurring_invoice.name)
  end

  def handle_event("save", params, socket) do
    rec_params = build_rec_params(params, :save)

    result =
      case socket.assigns.live_action do
        :new -> RecurringInvoices.create(rec_params)
        :edit -> RecurringInvoices.update(socket.assigns.recurring_invoice, rec_params)
      end

    case result do
      {:ok, _recurring_invoice} ->
        socket =
          socket
          |> put_flash(:info, "Recurring Invoice successfully saved")
          |> push_redirect(to: Routes.recurring_invoices_index_path(socket, :index))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", params, socket) do
    rec_params = build_rec_params(params, :validate)
    changeset = RecurringInvoices.change(socket.assigns.recurring_invoice, rec_params)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:items, rec_params["items"])

    {:noreply, socket}
  end

  def handle_event("add_item", _, socket) do
    {:noreply, assign(socket, :items, socket.assigns.items ++ [%{}])}
  end

  def handle_event("remove_item", %{"item-id" => item_id}, socket) do
    index = String.to_integer(item_id)
    {:noreply, assign(socket, items: List.delete_at(socket.assigns.items, index))}
  end

  def handle_info({:update_changeset, params}, socket) do
    changeset =
      socket.assigns.recurring_invoice
      |> RecurringInvoices.change(params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @spec build_rec_params(map, :save | :validate) :: map
  defp build_rec_params(params, msg) do
    taxes_params = get_taxes_params(params)

    items =
      params
      |> get_items_params()
      |> merge_taxes_with_item(taxes_params)
      |> maybe_remove_virtual_unitary_cost(msg)

    Map.put(params["recurring_invoice"], "items", items)
  end

  @spec maybe_remove_virtual_unitary_cost(list, :save | :validate) :: [] | [map]
  defp maybe_remove_virtual_unitary_cost(items, :save) do
    Enum.map(items, &Map.delete(&1, "virtual_unitary_cost"))
  end

  defp maybe_remove_virtual_unitary_cost(items, _), do: items

  @spec get_items_params(map) :: map
  defp get_items_params(params), do: params["items"] || %{}
  @spec get_taxes_params(map) :: map
  defp get_taxes_params(params), do: params["invoice"]["items"] || %{}

  @spec merge_taxes_with_item(map, map) :: [] | [map]
  defp merge_taxes_with_item(items_params, taxes_params),
    do:
      Enum.map(items_params, fn {index, item} ->
        Map.merge(item, taxes_params[index] || %{})
      end)
end

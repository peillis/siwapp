defmodule SiwappWeb.RecurringInvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Phoenix.HTML.FormData
  alias Siwapp.Commons
  alias Siwapp.Invoices.Item
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
    new_recurring_invoice = %RecurringInvoice{items: [%{}]}

    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Recurring Invoice")
    |> assign(:recurring_invoice, new_recurring_invoice)
    |> assign(:changeset, RecurringInvoices.change(new_recurring_invoice))
    |> assign(:customer_name, "")
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    recurring_invoice = RecurringInvoices.get!(String.to_integer(id), :preload)

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, recurring_invoice.name)
    |> assign(:recurring_invoice, recurring_invoice)
    |> assign(:changeset, RecurringInvoices.change(recurring_invoice))
    |> assign(:customer_name, recurring_invoice.name)
  end

  def handle_event("save", params, socket) do
    rec_params = build_rec_params(params)

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
    rec_params = build_rec_params(params)
    changeset = RecurringInvoices.change(socket.assigns.recurring_invoice, rec_params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add_item", _, socket) do
    items = Ecto.Changeset.get_field(socket.assigns.changeset, :items)
    [Item.changeset(%Item{}, %{})]

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:items, items)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_item", %{"item-id" => item_id}, socket) do
    items =
      Ecto.Changeset.get_field(socket.assigns.changeset, :items)
      |> List.delete_at(String.to_integer(item_id))

    changeset =
      socket.assigns.changeset
      |> Map.put(:changes, %{items: items})

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_info({:update_changeset, params}, socket) do
    changeset =
      socket.assigns.recurring_invoice
      |> RecurringInvoices.change(params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  # Replicates inputs_for behavior for recurring_invoice's items even when there's no association
  # using items_transformed, which are the changed items
  @spec pseudo_inputs_for(Ecto.Changeset.t()) :: [FormData.t()]
  defp pseudo_inputs_for(changeset) do
    items_changesets = Ecto.Changeset.get_field(changeset, :items)

    Enum.map(Enum.with_index(items_changesets), fn {item_changeset, i} ->
      indexed_item_form(item_changeset, i)
    end)
  end

  @spec indexed_item_form(Ecto.Changeset.t(), non_neg_integer()) :: FormData.t()
  defp indexed_item_form(item_changeset, index) do
    fi = FormData.to_form(item_changeset, [])

    %{
      fi
      | id: "recurring_invoice_items_#{index}",
        name: "items[#{index}]",
        index: index,
        options: [],
        errors: fi.source.errors
    }
  end

  @spec build_rec_params(map) :: map
  defp build_rec_params(params) do
    taxes_params = get_taxes_params(params)

    items =
      params
      |> get_items_params()
      |> merge_taxes_with_item(taxes_params)

    Map.put(params["recurring_invoice"], "items", items)
  end

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

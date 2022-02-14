defmodule SiwappWeb.RecurringInvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Phoenix.HTML.FormData
  alias SiwappWeb.ItemView

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

  def handle_event("save", %{"recurring_invoice" => params}, socket) do
    params = Map.put(params, "items", Enum.map(params["items"], fn {_index, item} -> item end))

    result =
      case socket.assigns.live_action do
        :new -> RecurringInvoices.create(params)
        :edit -> RecurringInvoices.update(socket.assigns.recurring_invoice, params)
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

  def handle_event("validate", %{"recurring_invoice" => params = %{"items" => _items}}, socket) do
    params = Map.put(params, "items", Enum.map(params["items"], fn {_index, item} -> item end))
    changeset = RecurringInvoices.change(socket.assigns.recurring_invoice, params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("validate", %{"recurring_invoice" => params}, socket) do
    changeset = RecurringInvoices.change(socket.assigns.recurring_invoice, params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add_item", _, socket) do
    changeset = ItemView.add_item(socket.assigns.changeset)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_item", %{"item-id" => item_id}, socket) do
    changeset = ItemView.remove_item(socket.assigns.changeset, String.to_integer(item_id))

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_info({:update_changeset, params}, socket) do
    changeset = RecurringInvoices.change(socket.assigns.recurring_invoice, params)

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
        name: "recurring_invoice[items][#{index}]",
        index: index,
        options: [],
        errors: fi.source.errors
    }
  end
end

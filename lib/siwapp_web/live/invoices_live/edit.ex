defmodule SiwappWeb.InvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Commons
  alias Siwapp.Invoices
  alias Siwapp.Invoices.{Invoice, Item}
  alias SiwappWeb.MetaAttributesComponent

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:series, Commons.list_series())}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    new_invoice = %Invoice{items: [%Item{taxes: []}]}

    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, new_invoice)
    |> assign(:changeset, Invoices.change(new_invoice))
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), :preload)

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, invoice.name)
    |> assign(:invoice, invoice)
    |> assign(:changeset, Invoices.change(invoice))
  end

  def handle_event("save", %{"invoice" => params, "meta" => meta}, socket) do
    params = MetaAttributesComponent.merge(params, meta)

    result =
      case socket.assigns.live_action do
        :new -> Invoices.create(params)
        :edit -> Invoices.update(socket.assigns.invoice, params)
      end

    case result do
      {:ok, _invoice} ->
        socket =
          socket
          |> put_flash(:info, "Invoice successfully saved")
          |> push_redirect(to: Routes.invoices_index_path(socket, :index))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"invoice" => params}, socket) do
    changeset =
      socket.assigns.invoice
      |> Invoices.change(params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add_item", _, socket) do
    items =
      Map.get(socket.assigns.changeset.changes, :items, socket.assigns.invoice.items) ++
        [Invoices.change_item(%Item{})]

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:items, items)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_item", %{"item-id" => item_id}, socket) do
    items =
      Map.get(socket.assigns.changeset.changes, :items, socket.assigns.invoice.items)
      |> List.delete_at(String.to_integer(item_id))

    changeset =
      socket.assigns.changeset
      |> Map.put(:changes, %{items: items})

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp get_existing_taxes(changeset, fi) do
    item =
      changeset
      |> Ecto.Changeset.get_field(:items)
      |> Enum.at(fi.index)

    item.taxes
    |> Enum.map(&{&1.name, &1.id})
  end

  defp item_net_amount(changeset, fi) do
    changeset
    |> Ecto.Changeset.get_field(:items)
    |> Enum.at(fi.index)
    |> Map.get(:net_amount)
  end

  defp net_amount(changeset), do: Ecto.Changeset.get_field(changeset, :net_amount)

  defp taxes_amounts(changeset), do: Ecto.Changeset.get_field(changeset, :taxes_amounts)

  defp gross_amount(changeset), do: Ecto.Changeset.get_field(changeset, :gross_amount)

end

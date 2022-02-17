defmodule SiwappWeb.InvoicesLive.Edit do
  @moduledoc false
  use SiwappWeb, :live_view

  alias SiwappWeb.InvoicesLive.CustomerComponent
  alias SiwappWeb.ItemView

  alias Siwapp.Commons
  alias Siwapp.Invoices
  alias Siwapp.Invoices.{Invoice, Item}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:multiselect_options, Commons.list_taxes_for_multiselect())
     |> assign(:series, Commons.list_series())
     |> assign(:currency_options, Invoices.list_currencies())
     |> assign(:customer_suggestions, [])}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    new_invoice = %Invoice{items: [%Item{taxes: []}]}
    changeset = Invoices.change(new_invoice)

    socket
    |> assign(:action, :new)
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, new_invoice)
    |> assign(:changeset, changeset)
    |> assign(:form_params, initial_params(changeset, :new))
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    invoice =
      Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series, :customer])

    changeset = Invoices.change(invoice)

    IO.inspect(initial_params(changeset, :edit))

    socket
    |> assign(:action, :edit)
    |> assign(:page_title, invoice.name)
    |> assign(:invoice, invoice)
    |> assign(:changeset, changeset)
    |> assign(:form_params, initial_params(changeset, :edit))
  end

  def handle_event("save", %{"invoice" => params}, socket) do
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

    {:noreply,
     socket
     |> assign(changeset: changeset)
     |> assign(form_params: params)}
  end

  def handle_event("add_item", _, socket) do
    params = socket.assigns.form_params

    next_item_index =
      params["items"]
      |> Enum.count()
      |> Integer.to_string()

    params = put_in(params, ["items", next_item_index], item_param())

    {:noreply,
     socket
     |> assign(changeset: Invoices.change(socket.assigns.invoice, params))
     |> assign(form_params: params)}
  end

  def handle_event("remove_item", %{"item-id" => item_index}, socket) do
    params =
      socket.assigns.form_params
      |> pop_in(["items", item_index])
      |> elem(1)

    {:noreply,
     socket
     |> assign(changeset: Invoices.change(socket.assigns.invoice, params))
     |> assign(form_params: params)}
  end

  def handle_info({:customer_updated, customer_params}, socket) do
    params =
      socket.assigns.form_params
      |> Map.merge(atom_keys_to_string(customer_params))

    {:noreply,
     socket
     |> assign(changeset: Invoices.change(socket.assigns.invoice, params))
     |> assign(form_params: params)}
  end

  def handle_info({:multiselect_updated, %{index: item_index, selected: selected_taxes}}, socket) do
    params =
      socket.assigns.form_params
      |> put_in(["items", Integer.to_string(item_index), "taxes"], selected_taxes)

    {:noreply,
     socket
     |> assign(changeset: Invoices.change(socket.assigns.invoice, params))
     |> assign(form_params: params)}
  end

  defp initial_params(changeset, :new) do
    changeset.changes
    |> atom_keys_to_string()
    |> Map.put("items", %{})
    |> put_in(["items", "0"], item_param())
  end

  defp initial_params(changeset, :edit) do
    changeset.data
    |> Map.from_struct()
    |> Map.take([
      :contact_person,
      :currency,
      :due_date,
      :email,
      :identification,
      :invoicing_address,
      :issue_date,
      :items,
      :meta_attributes,
      :name,
      :notes,
      :number,
      :series_id,
      :shipping_address,
      :terms
    ])
    |> atom_keys_to_string()
    |> transform_items_to_params()
  end

  defp transform_items_to_params(params) do
    items =
      params
      |> Map.get("items")
      |> Enum.with_index()
      |> Map.new(fn {item, index} -> {Integer.to_string(index), item_param(item)} end)

    Map.put(params, "items", items)
  end

  defp atom_keys_to_string(map), do: Map.new(map, fn {k, v} -> {Atom.to_string(k), v} end)

  defp item_param(item \\ %Item{taxes: []}) do
    item
    |> Map.from_struct()
    |> Map.take([:description, :discount, :taxes, :quantity, :virtual_unitary_cost])
    |> atom_keys_to_string()
  end
end

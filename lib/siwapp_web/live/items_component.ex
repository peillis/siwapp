defmodule SiwappWeb.ItemsComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Phoenix.HTML.FormData
  alias Siwapp.Invoices.Item
  alias SiwappWeb.PageView
  alias Ecto.Changeset

  import SiwappWeb.InvoiceFormHelpers

  def mount(socket) do
    {:ok, assign(socket, :multiselect_options, Siwapp.Commons.list_taxes_for_multiselect())}
  end

  def update(assigns, socket) do
    {:ok,
    socket
    |> assign(f: assigns.f)
    |> assign(changeset: assigns.f.source)
    |> assign(inputs_for: assigns.inputs_for)}
  end

  def handle_event("add", _, socket) do
    params =
      socket.assigns.changeset
      |> Ecto.Changeset.apply_changes()
      |> get_params()

    next_item_index =
      params["items"]
      |> Enum.count()
      |> Integer.to_string()

    send(self(), {:params_updated, put_in(params, ["items", next_item_index], item_param())})

    {:noreply, socket}
  end

  def handle_event("remove", %{"item-id" => item_index}, socket) do
    params =
      socket.assigns.changeset
      |> Ecto.Changeset.apply_changes()
      |> get_params()
      |> pop_in(["items", item_index])
      |> elem(1)

    send(self(), {:params_updated, params})

    {:noreply, socket}
  end

  @spec item_net_amount(Ecto.Changeset.t(), FormData.t()) :: binary
  defp item_net_amount(changeset, fi) do
    value = get_field(fi.source, :net_amount)
    currency = get_field(changeset, :currency)
    PageView.money_format(value, currency, symbol: false, separator: "")
  end

  defp net_amount(changeset) do
    changeset
    |> Changeset.get_field(:net_amount)
    |> PageView.money_format(Changeset.get_field(changeset, :currency))
  end

  defp taxes_amounts(changeset) do
    changeset
    |> Changeset.get_field(:taxes_amounts)
    |> Enum.map(fn {k, v} ->
      {k, PageView.money_format(v, Changeset.get_field(changeset, :currency))}
    end)
  end

  defp gross_amount(changeset) do
    changeset
    |> Changeset.get_field(:gross_amount)
    |> PageView.money_format(Changeset.get_field(changeset, :currency))
  end
end

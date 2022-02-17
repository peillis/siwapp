defmodule SiwappWeb.ItemsComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Phoenix.HTML.FormData
  alias Siwapp.Invoices.Item
  alias SiwappWeb.PageView

  import Ecto.Changeset

  def handle_event("add", _, socket) do
    params = socket.assigns.form_params

    next_item_index =
      params["items"]
      |> Enum.count()
      |> Integer.to_string()

    params = put_in(params, ["items", next_item_index], item_param())

    send(self(), {:items_updated, params})

    {:noreply, socket}
  end

  def handle_event("remove", %{"item-id" => item_index}, socket) do
    params =
      socket.assigns.form_params
      |> pop_in(["items", item_index])
      |> elem(1)

    send(self(), {:items_updated, params})

    {:noreply, socket}
  end

  @spec get_existing_taxes(FormData.t()) :: [] | [tuple]
  defp get_existing_taxes(fi) do
    get_field(fi.source, :taxes)
    |> Enum.map(&{&1.name, &1.id})
  end

  @spec item_net_amount(Ecto.Changeset.t(), FormData.t()) :: binary
  defp item_net_amount(changeset, fi) do
    value = get_field(fi.source, :net_amount)
    currency = get_field(changeset, :currency)
    PageView.money_format(value, currency, symbol: false, separator: "")
  end

  defp net_amount(changeset) do
    get_field(changeset, :net_amount)
    |> PageView.money_format(get_field(changeset, :currency))
  end

  defp taxes_amounts(changeset) do
    get_field(changeset, :taxes_amounts)
    |> Enum.map(fn {k, v} ->
      {k, PageView.money_format(v, get_field(changeset, :currency))}
    end)
  end

  defp gross_amount(changeset) do
    get_field(changeset, :gross_amount)
    |> PageView.money_format(get_field(changeset, :currency))
  end

  defp item_param(item \\ %Item{taxes: []}) do
    item
    |> Map.from_struct()
    |> Map.take([:description, :discount, :taxes, :quantity, :virtual_unitary_cost])
    |> atom_keys_to_string()
  end

  defp atom_keys_to_string(map), do: Map.new(map, fn {k, v} -> {Atom.to_string(k), v} end)

end

defmodule SiwappWeb.ItemView do
  use SiwappWeb, :view

  alias Phoenix.HTML.FormData
  alias Siwapp.Invoices.Item
  alias SiwappWeb.PageView

  import Ecto.Changeset

  @spec get_existing_taxes(FormData.t()) :: [] | [tuple]
  def get_existing_taxes(fi) do
    fi.source
    |> get_field(:taxes)
    |> Enum.map(&{&1.name, &1.id})
  end

  @spec item_net_amount(FormData.t()) :: binary
  def item_net_amount(fi) do
    fi.source
    |> get_field(:net_amount)
    |> Kernel./(100)
    |> :erlang.float_to_binary(decimals: 2)
  end

  def add_item(changeset) do
    items =
      get_field(changeset, :items) ++
        [Item.changeset(%Item{}, %{})]

    put_change(changeset, :items, items)
  end

  def remove_item(changeset, index) do
    items =
      changeset
      |> get_field(:items)
      |> List.delete_at(index)

    put_change(changeset, :items, items)
  end

  defp net_amount(changeset) do
    amount = get_field(changeset, :net_amount)
    currency = get_field(changeset, :currency)

    PageView.set_currency(amount, currency)
  end

  defp taxes_amounts(changeset) do
    amounts = get_field(changeset, :taxes_amounts)

    Enum.map(amounts, fn {k, v} ->
      {k, PageView.set_currency(v, get_field(changeset, :currency))}
    end)
  end

  defp gross_amount(changeset) do
    amount = get_field(changeset, :gross_amount)
    currency = get_field(changeset, :currency)

    PageView.set_currency(amount, currency)
  end
end

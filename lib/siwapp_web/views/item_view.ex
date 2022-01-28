defmodule SiwappWeb.ItemView do
  use SiwappWeb, :view

  alias Phoenix.HTML.FormData
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Item

  def get_existing_taxes(changeset, fi) do
    if fi.id =~  "recurring_invoice"do
      taxes = fi.params["taxes"]
      if taxes, do: taxes_with_id(taxes), else: []
    else
      item =
        changeset
        |> Ecto.Changeset.get_field(:items)
        |> Enum.at(fi.index)

      item.taxes
      |> Enum.map(&{&1.name, &1.id})
    end
  end

  def pseudo_inputs_for(f, items) do
    if f.id == "invoice" do
      inputs_for(f, :items)
    else
      Enum.map(Enum.with_index(items), fn {item, i} -> alt_inputs_for(item, i) end)
    end
  end

  def alt_inputs_for(item, index) do
    item_changeset = Invoices.change_item(%Item{}, item)
    fi = FormData.to_form(item_changeset, [])
    %{ fi | id: "recurring_invoice_items_"<> Integer.to_string(index), name: "items[#{index}]", index: index, options: []}
  end

  def item_net_amount(changeset, fi) do
    if fi.id =~ "recurring_invoice" do
      Ecto.Changeset.get_field(fi.source, :net_amount)
    else
      changeset
      |> Ecto.Changeset.get_field(:items)
      |> Enum.at(fi.index)
      |> Map.get(:net_amount)
    end
  end

  defp taxes_with_id(taxes), do: Enum.map(taxes, fn tax -> {tax, Siwapp.Commons.get_tax_id(tax)} end)

  defp net_amount(changeset), do: Ecto.Changeset.get_field(changeset, :net_amount)
  defp taxes_amounts(changeset), do: Ecto.Changeset.get_field(changeset, :taxes_amounts) || []
  defp gross_amount(changeset), do: Ecto.Changeset.get_field(changeset, :gross_amount)
end

defmodule SiwappWeb.ItemView do
  use SiwappWeb, :view

  alias Phoenix.HTML.FormData
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Item
  alias SiwappWeb.PageView

  @doc """
  Replicates inputs_for behavior for recurring_invoice's items even when there's no association
  """
  @spec pseudo_inputs_for(FormData.t(), list) :: [FormData.t()]
  def pseudo_inputs_for(f, items) do
    if f.id == "invoice" do
      inputs_for(f, :items)
    else
      Enum.map(Enum.with_index(items), fn {item, i} -> indexed_item_form(item, i) end)
    end
  end

  @doc """
  Gets unitary_cost from item changeset to set it as hidden input so it gets to items' params (managed by LiveView)
  """
  @spec set_unitary_cost(map) :: binary
  def set_unitary_cost(changes) do
    Integer.to_string(Map.get(changes, :unitary_cost, 0))
  end

  @spec indexed_item_form(map, non_neg_integer()) :: FormData.t()
  def indexed_item_form(item, index) do
    item_changeset = Invoices.change_item(%Item{}, item)
    fi = FormData.to_form(item_changeset, [])

    %{
      fi
      | id: "recurring_invoice_items_" <> Integer.to_string(index),
        name: "items[#{index}]",
        index: index,
        options: []
    }
  end

  @spec get_existing_taxes(Ecto.Changeset.t(), FormData.t()) :: [] | [tuple]
  def get_existing_taxes(changeset, fi) do
    if fi.id =~ "recurring_invoice" do
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

  @spec item_net_amount(Ecto.Changeset.t(), FormData.t()) :: binary
  def item_net_amount(changeset, fi) do
    net_amount =
      if fi.id =~ "recurring_invoice" do
        Ecto.Changeset.get_field(fi.source, :net_amount)
      else
        changeset
        |> Ecto.Changeset.get_field(:items)
        |> Enum.at(fi.index)
        |> Map.get(:net_amount)
      end

    :erlang.float_to_binary(net_amount / 100, decimals: 2)
  end

  defp net_amount(changeset) do
    Ecto.Changeset.get_field(changeset, :net_amount)
    |> PageView.set_currency(Ecto.Changeset.get_field(changeset, :currency))
  end

  defp taxes_amounts(changeset) do
    Ecto.Changeset.get_field(changeset, :taxes_amounts) ||
      []
      |> Enum.map(fn {k, v} ->
        {k, PageView.set_currency(v, Ecto.Changeset.get_field(changeset, :currency))}
      end)
  end

  defp gross_amount(changeset) do
    Ecto.Changeset.get_field(changeset, :gross_amount)
    |> PageView.set_currency(Ecto.Changeset.get_field(changeset, :currency))
  end

  @spec taxes_with_id([] | [binary]) :: [] | [tuple]
  defp taxes_with_id(taxes),
    do: Enum.map(taxes, fn tax -> {tax, Siwapp.Commons.get_tax_by_name(tax).id} end)
end

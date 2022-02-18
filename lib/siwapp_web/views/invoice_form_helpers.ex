defmodule SiwappWeb.InvoiceFormHelpers do
  @moduledoc """
  Helpers functions for adapting invoice params to the form format
  """

  alias Siwapp.Invoices.Item

  def get_params(invoice) do
    invoice
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

  def transform_items_to_params(params) do
    items =
      params
      |> Map.get("items")
      |> Enum.with_index()
      |> Map.new(fn {item, index} -> {Integer.to_string(index), item_param(item)} end)

    Map.put(params, "items", items)
  end

  def item_param(item \\ %Item{taxes: []}) do
    item = if is_struct(item, Ecto.Changeset), do: Ecto.Changeset.apply_changes(item), else: item

    item
    |> Map.from_struct()
    |> Map.take([:description, :discount, :quantity, :virtual_unitary_cost])
    |> Map.put(:taxes, Enum.map(item.taxes, & &1.name))
    |> atom_keys_to_string()
  end

  def atom_keys_to_string(map), do: Map.new(map, fn {k, v} -> {Atom.to_string(k), v} end)
end

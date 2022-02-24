defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  alias Siwapp.Invoices.Item

  @doc """
  Returns a string of money, which is formed by amount and currency. Options
  can be given. Default are [symbol: true, separator: ","]. Check Money.to_string
  to see more options available
  """
  @spec money_format(number, atom | binary, keyword) :: binary
  def money_format(value, currency, options \\ []) do
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string(options)
  end

  @spec get_item_params(Item.t()) :: map
  def get_item_params(item \\ %Item{taxes: Commons.default_taxes_names()}) do
    item
    |> Map.from_struct()
    |> Map.take([:description, :discount, :quantity, :virtual_unitary_cost])
    |> Map.put(:taxes, Enum.map(item.taxes, & &1.name))
    |> SiwappWeb.PageView.atom_keys_to_string()
  end

  @spec atom_keys_to_string(map) :: map
  def atom_keys_to_string(map), do: Map.new(map, fn {k, v} -> {Atom.to_string(k), v} end)

  @spec reference(binary, integer) :: binary
  def reference(series_code, number), do: series_code <> "-#{number}"
end

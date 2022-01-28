defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  @spec set_currency(float | integer, atom | binary) :: binary
  def set_currency(value, nil), do: set_currency(value, :USD)

  def set_currency(value, currency) do
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string()
  end
end

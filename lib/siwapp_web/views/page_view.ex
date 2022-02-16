defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  @spec set_currency(float | integer, atom | binary) :: binary
  def set_currency(value, currency) do
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string()
  end

  @spec set_currency(float | integer, atom | binary, keyword) :: binary
  def set_currency(value, currency, symbol: symbol) do
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string(symbol: symbol)
  end
end

defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  @spec set_currency(number, atom | binary, keyword) :: binary
  def set_currency(value, currency, options \\ []) do
    default = [symbol: true, separator: ","]
    options = Keyword.merge(default, options)

    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string(symbol: options[:symbol], separator: options[:separator])
  end
end

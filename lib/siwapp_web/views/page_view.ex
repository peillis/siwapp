defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  @doc """
  Returns a string of money, amount and currency, if last one
  is provided. Otherwise, returns only string of amount.
  """
  @spec set_currency(float | integer, atom | binary) :: binary
  def set_currency(value, nil), do: "#{round(value)}"

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

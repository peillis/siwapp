defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  @doc """
  Returns a string of money, amount and currency, if last one is
  provided. Otherwise, returns only string of amount in money format
  """
  @spec money_format(float | integer, atom, [{:symbol, atom}]) :: binary
  def money_format(value, nil) do
    value
    |> round()
    |> Money.new(:USD)
    |> Money.to_string(symbol: false)
  end

  @spec money_format(number, atom | binary, keyword) :: binary
  def money_format(value, currency, options \\ []) do
    default = [symbol: true, separator: ","]
    options = Keyword.merge(default, options)
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string(symbol: options[:symbol], separator: options[:separator])
  end
end

defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  @doc """
  Returns a string of money, amount and currency, if last one
  is provided. Otherwise, returns only string of amount.
  """
  @spec set_currency(float | integer, atom | binary) :: binary
  def set_currency(value, nil), do: "#{round(value)}"

  def set_currency(value, currency) do
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string()
  end
end

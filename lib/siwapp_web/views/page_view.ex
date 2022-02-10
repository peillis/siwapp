defmodule SiwappWeb.PageView do
  use SiwappWeb, :view

  @spec set_currency(float | integer, atom | binary) :: binary
  def set_currency(value, nil), do: set_currency(value, Siwapp.Settings.value(:currency))

  def set_currency(value, currency) do
    value
    |> round()
    |> Money.new(currency)
    |> Money.to_string()
  end

  def list_currencies do
    default_currency = Siwapp.Settings.value(:currency)
    Enum.uniq([default_currency] ++ primary_currencies() ++ all_currencies())
  end

  defp all_currencies do
    Money.Currency.all()
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
    |> Enum.sort()
  end

  defp primary_currencies, do: ["USD", "EUR", "GBP"]
end

defmodule Siwapp.Invoices.AmountHelper do
  @moduledoc """
  Helper functions for Item and Payments schemas when handling with amounts
  """
  import Ecto.Changeset

  alias SiwappWeb.PageView

  @spec set_amount(Ecto.Changeset.t(), atom(), atom(), atom() | binary()) :: Ecto.Changeset.t()
  def set_amount(changeset, field, virtual_field, currency) do
    virtual_amount = get_field(changeset, virtual_field)

    cond do
      is_nil(virtual_amount) ->
        changeset

      virtual_amount == "" ->
        put_change(changeset, field, 0)

      true ->
        case Money.parse(virtual_amount, currency) do
          {:ok, %Money{amount: amount}} -> put_change(changeset, field, amount)
          :error -> add_error(changeset, virtual_field, "Invalid format")
        end
    end
  end

  @spec set_virtual_amount(Ecto.Changeset.t(), atom(), atom(), atom() | binary()) ::
          Ecto.Changeset.t()
  def set_virtual_amount(changeset, field, virtual_field, currency) do
    if is_nil(get_field(changeset, field)) do
      changeset
    else
      amount = get_field(changeset, field)

      virtual_amount = PageView.money_format(amount, currency, symbol: false, separator: "")

      put_change(changeset, virtual_field, virtual_amount)
    end
  end
end

defmodule Siwapp.Invoices.AmountHelper do
  @moduledoc """
  Helper functions for Item and Payments schemas when handling with amounts
  """
  import Ecto.Changeset

  alias SiwappWeb.PageView

  @spec set_amount(Ecto.Changeset.t(), atom(), atom(), atom() | binary()) :: Ecto.Changeset.t()
  def set_amount(changeset, field, virtual_field, currency) do
    case get_field(changeset, virtual_field) do
      nil ->
        set_virtual_amount(changeset, field, virtual_field, currency)

      "" ->
        put_change(changeset, field, 0)

      virtual_amount ->
        case Money.parse(virtual_amount, currency) do
          {:ok, %Money{amount: amount}} -> put_change(changeset, field, amount)
          :error -> add_error(changeset, virtual_field, "Invalid format")
        end
    end
  end

  @spec set_virtual_amount(Ecto.Changeset.t(), atom(), atom(), atom() | binary()) ::
          Ecto.Changeset.t()
  defp set_virtual_amount(changeset, field, virtual_field, currency) do
    case get_field(changeset, field) do
      nil ->
        changeset

      amount ->
        virtual_amount = PageView.money_format(amount, currency, symbol: false, separator: "")

        put_change(changeset, virtual_field, virtual_amount)
    end
  end
end

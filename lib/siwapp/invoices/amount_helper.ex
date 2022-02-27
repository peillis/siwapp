defmodule Siwapp.Invoices.AmountHelper do
  @moduledoc """
  Helper functions for Item and Payments schemas when handling with amounts
  """
  import Ecto.Changeset

  @doc """
  Given the virtual_field amount sets the field amount to that.
  If the virtual_field is not set, then is set to the field.
  """
  @spec set_amount(Ecto.Changeset.t(), atom(), atom(), atom() | binary()) :: Ecto.Changeset.t()
  def set_amount(changeset, field, virtual_field, currency) do
    case get_field(changeset, virtual_field) do
      nil ->
        set_virtual_amount(changeset, field, virtual_field, currency)

      "" ->
        put_change(changeset, field, 0)

      virtual_amount ->
        case Money.parse(virtual_amount, currency) do
          {:ok, money} -> put_change(changeset, field, money.amount)
          :error -> add_error(changeset, virtual_field, "Invalid format")
        end
    end
  end

  @spec set_virtual_amount(Ecto.Changeset.t(), atom, atom, atom | binary) :: Ecto.Changeset.t()
  defp set_virtual_amount(changeset, field, virtual_field, currency) do
    case get_field(changeset, field) do
      nil ->
        changeset

      amount ->
        virtual_amount = Money.new(amount, currency) |> Money.to_decimal()
        put_change(changeset, virtual_field, virtual_amount)
    end
  end
end

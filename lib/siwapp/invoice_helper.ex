defmodule Siwapp.InvoiceHelper do
  @moduledoc """
  Helper functions for Invoice and RecurringInvoice schemas
  """

  import Ecto.Changeset

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer

  def maybe_find_customer_or_new(changeset) do
    if is_nil(get_field(changeset, :customer_id)) do
      find_customer_or_new(changeset)
    else
      if changes_in_name_or_identification?(changeset) do
        changeset
        |> put_change(:customer_id, nil)
        |> find_customer_or_new()
      else
        changeset
      end
    end
  end

  @doc """
  Performs the totals calculations for net_amount, taxes_amounts and gross_amount fields.
  """
  @spec calculate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def calculate(changeset) do
    changeset
    |> set_net_amount()
    |> set_taxes_amounts()
    |> set_gross_amount()
  end

  defp find_customer_or_new(changeset) do
    identification = get_field(changeset, :identification)
    name = get_field(changeset, :name)

    case Customers.get(identification, name) do
      nil ->
        customer_changeset = Customer.changeset(%Customer{}, changeset.changes)

        changeset
        |> put_assoc(:customer, customer_changeset)
        |> bring_customer_errors()

      customer ->
        put_change(changeset, :customer_id, customer.id)
    end
  end

  defp changes_in_name_or_identification?(changeset) do
    Map.has_key?(changeset.changes, :name) or
      Map.has_key?(changeset.changes, :identification)
  end

  defp bring_customer_errors(changeset) do
    changeset
    |> traverse_errors(& &1)
    |> Map.get(:customer, [])
    |> Enum.reduce(changeset, fn error, new_changeset ->
      add_error(new_changeset, error)
    end)
  end

  defp add_error(changeset, {key, [{message, opts}]}),
    do: add_error(changeset, key, message, opts)

  defp set_net_amount(changeset) do
    total_net_amount =
      get_field(changeset, :items)
      |> Enum.map(& &1.net_amount)
      |> Enum.sum()
      |> round()

    put_change(changeset, :net_amount, total_net_amount)
  end

  defp set_taxes_amounts(changeset) do
    total_taxes_amounts =
      get_field(changeset, :items)
      |> Enum.map(& &1.taxes_amount)
      |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _, v1, v2 -> v1 + v2 end))

    put_change(changeset, :taxes_amounts, total_taxes_amounts)
  end

  defp set_gross_amount(changeset) do
    net_amount = get_field(changeset, :net_amount)

    taxes_amount =
      get_field(changeset, :taxes_amounts)
      |> Map.values()
      |> Enum.sum()

    put_change(changeset, :gross_amount, round(net_amount + taxes_amount))
  end
end

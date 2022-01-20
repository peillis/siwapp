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

  defp find_customer_or_new(changeset) do
    identification = get_field(changeset, :identification)
    name = get_field(changeset, :name)

    case Customers.get(identification, name) do
      nil ->
        customer_changeset = Customer.changeset(%Customer{}, changeset.changes)
        changeset = put_assoc(changeset, :customer, customer_changeset)

        changeset
        |> traverse_errors(& &1)
        |> bring_customer_errors(changeset)

      customer ->
        put_change(changeset, :customer_id, customer.id)
    end
  end

  defp changes_in_name_or_identification?(changeset) do
    Map.has_key?(changeset.changes, :name) or
      Map.has_key?(changeset.changes, :identification)
  end

  defp bring_customer_errors(errors, changeset) do
    errors
    |> Map.get(:customer, [])
    |> Enum.reduce(changeset, fn error, new_changeset ->
      add_customer_error(new_changeset, error)
    end)
  end

  defp add_customer_error(changeset, {key, [{message, opts}]}),
    do: add_error(changeset, key, message, opts)
end

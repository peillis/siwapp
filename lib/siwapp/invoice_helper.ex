defmodule Siwapp.InvoiceHelper do
  @moduledoc """
  Helper functions for Invoice and RecurringInvoice schemas
  """

  import Ecto.Changeset

  alias Siwapp.Customers
  alias Siwapp.Customers.Customer

  def find_customer_or_new(changeset) do
    if is_nil(get_field(changeset, :customer_id)) do
      identification = get_field(changeset, :identification)
      name = get_field(changeset, :name)

      case Customers.get(identification, name) do
        nil ->
          customer = Customer.changeset(%Customer{}, changeset.changes)
          changeset
          |> put_assoc(:customer, customer)
          |> traverse_customer_errors()

        customer ->
          put_change(changeset, :customer_id, customer.id)
      end
    else
      customer_changeset = Customer.changeset(%Customer{}, changeset.changes)
      changeset = bring_customer_errors(customer_changeset.errors, changeset)

      IO.inspect changeset
    end
  end

  defp traverse_customer_errors(changeset) do
    traverse_errors(changeset, & &1)
    |> Map.get(:customer, [])
    |> Enum.map(fn {key, [value]} -> {key, value} end)
    |> bring_customer_errors(changeset)
  end

  defp bring_customer_errors(errors, changeset) do
    errors
    |> Enum.reduce(changeset, fn error, changeset -> add_customer_error(changeset, error) end)
  end

  defp add_customer_error(changeset, {key, {message, opts}}) do
    add_error(changeset, key, message, opts)
  end
end

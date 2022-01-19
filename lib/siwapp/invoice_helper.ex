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
          customer_changeset = Customer.changeset(%Customer{}, changeset.changes)
          changeset = put_assoc(changeset, :customer, customer_changeset)

          changeset
          |> traverse_errors(& &1)
          |> Map.get(:customer, [])
          |> bring_customer_errors(changeset)

        customer ->
          put_change(changeset, :customer_id, customer.id)
      end
    else
      customer_changeset = get_customer_changeset(changeset)
      errors = Enum.map(customer_changeset.errors, fn {key, {message, opts}} -> {key, [{message, opts}]} end)

      bring_customer_errors(errors, changeset)
    end
  end

  defp get_customer_changeset(changeset) do
    customer_data =
      Map.take(changeset.data, [
        :name,
        :identification,
        :email,
        :contact_person,
        :invoicing_address,
        :shipping_address
      ])

      Customer.changeset(struct(Customer, customer_data), changeset.changes)
  end

  defp bring_customer_errors(errors, changeset) do
    Enum.reduce(errors, changeset, fn error, new_changeset -> add_customer_error(new_changeset, error) end)
  end

  defp add_customer_error(changeset, {key, [{message, opts}]}), do: add_error(changeset, key, message, opts)
end

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
          put_assoc(changeset, :customer, customer)

        customer ->
          put_change(changeset, :customer_id, customer.id)
      end
    else
      changeset
    end
  end

  def bring_customer_errors(changeset) do
    customer_changes =
      Map.take(changeset.changes, [
        :name,
        :identification,
        :email,
        :contact_person,
        :invoicing_address,
        :shipping_address
      ])

    customer_data =
      Map.take(changeset.data, [
        :name,
        :identification,
        :email,
        :contact_person,
        :invoicing_address,
        :shipping_address
      ])

    customer_changeset = Customer.changeset(struct(Customer, customer_data), customer_changes)

    customer_changeset.errors
    |> Enum.reduce(changeset, fn error, changeset -> add_customer_error(changeset, error) end)
  end

  defp add_customer_error(changeset, {key, {message, opts}}) do
    add_error(changeset, key, message, opts)
  end
end

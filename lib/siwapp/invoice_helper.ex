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
end

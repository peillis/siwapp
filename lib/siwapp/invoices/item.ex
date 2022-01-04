defmodule Siwapp.Invoices.Item do
  @moduledoc """
  Item
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Siwapp.Commons.Tax
  alias Siwapp.Invoices.Invoice

  @fields [:quantity, :discount, :description, :unitary_cost, :deleted_at, :invoice_id]

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string
    field :unitary_cost, :integer, default: 0
    field :deleted_at, :utc_datetime
    field :net_amount, :float, virtual: true
    field :taxes_amount, :map, virtual: true
    belongs_to :invoice, Invoice

    many_to_many :taxes, Tax, join_through: "items_taxes"
  end

  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, @fields)
    |> cast_assoc(:taxes)
    |> foreign_key_constraint(:invoice_id)
    |> validate_length(:description, max: 20_000)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> set_net_amount()
    |> set_taxes_amount()
  end

  def set_net_amount(changeset) do
    quantity = get_field(changeset, :quantity)
    unitary_cost = get_field(changeset, :unitary_cost)
    discount = get_field(changeset, :discount)

    net_amount = quantity * unitary_cost - quantity * unitary_cost * discount / 100

    put_change(changeset, :net_amount, net_amount)
  end

  def set_taxes_amount(changeset) do
    case get_field(changeset, :taxes) do
      [] ->
        changeset

      taxes ->
        net_amount = get_field(changeset, :net_amount)

        taxes_amounts =
          for tax <- taxes, into: %{} do
            {tax.id, tax.value * net_amount / 100}
          end

        put_change(changeset, :taxes_amount, taxes_amounts)
    end
  end
end

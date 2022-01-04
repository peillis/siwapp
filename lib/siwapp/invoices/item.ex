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

    many_to_many :taxes, Tax,
      join_through: "items_taxes",
      on_delete: :delete_all
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

    changeset
    |> put_change(:net_amount, quantity * unitary_cost - quantity * unitary_cost * discount / 100)
  end

  def set_taxes_amount(changeset) do
    taxes = get_field(changeset, :taxes)

    if taxes == [] do
      changeset
    else
      changeset
      |> put_change(:taxes_amount, taxes_amount(changeset))
    end
  end

  defp taxes_amount(changeset) do
    net_amount = get_field(changeset, :net_amount)
    taxes = get_field(changeset, :taxes)

    for tax <- taxes, id = tax.id, value = tax.value, into: %{} do
      {id, value * net_amount / 100}
    end
  end
end

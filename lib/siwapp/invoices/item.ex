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
    quantity = get_field_or_empty(changeset, :quantity)
    unitary_cost = get_field_or_empty(changeset, :unitary_cost)
    discount = get_field_or_empty(changeset, :discount)

    changeset
    |> put_change(:net_amount, quantity * unitary_cost - quantity * unitary_cost * discount / 100)
  end

  def set_taxes_amount(changeset) do
    taxes = get_field_or_empty(changeset, :taxes)

    if taxes == [] do
      changeset
    else
      changeset
      |> put_change(:taxes_amount, taxes_amount(changeset))
    end
  end

  defp taxes_amount(changeset) do
    net_amount = get_field_or_empty(changeset, :net_amount)
    taxes = get_field_or_empty(changeset, :taxes)

    for tax <- taxes do
      Map.new([{tax.id, tax.value * net_amount / 100}])
    end
    |> Enum.reduce(fn x, acc ->
      Map.merge(x, acc, fn _key, map1, map2 ->
        for {k, v1} <- map1, into: %{}, do: {k, v1 + map2[k]}
      end)
    end)
  end

  defp get_field_or_empty(changeset, field) do
    get_field(changeset, field) || ""
  end
end

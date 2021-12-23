defmodule Siwapp.Invoices.Item do
  use Ecto.Schema

  import Ecto.Changeset

  alias Siwapp.Invoices.Invoice
  alias Siwapp.Commons.Tax

  @fields [:quantity, :discount, :description, :unitary_cost, :deleted_at, :invoice_id]

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string
    field :unitary_cost, :integer, default: 0
    field :deleted_at, :utc_datetime
    field :net_amount, :integer, virtual: true
    field :taxes_amount, {:array, :map}, virtual: true
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
    |> validate_length(:description, max: 20000)
    |> validate_number(:quantity, greater_than_or_equal_to: 1)
    |> validate_number(:discount, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  def put_into_database(item) do
    item
    |> Map.put(:net_amount, net_amount(item))
    |> Map.put(:taxes_amount, taxes_amount(item))
  end

  def base_amount(item), do: item.quantity * item.unitary_cost

  def discount_amount(item), do: base_amount(item) * item.discount / 100

  def net_amount(item), do: base_amount(item) - discount_amount(item)

  def taxes_amount(item) do
    for tax <- item.taxes do
      id = tax.id
      value = tax.value * net_amount(item) / 100

      Map.new([{id, value}])
    end
  end
end

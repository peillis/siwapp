defmodule Siwapp.Schema.Item do
  use Ecto.Schema
  alias Siwapp.Schema.{Invoice, Tax}
  import Ecto.Changeset
  @fields [:quantity, :discount, :description, :unitary_cost, :deleted_at, :invoice_id]

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string
    field :unitary_cost, :integer, default: 0
    field :deleted_at, :utc_datetime
    belongs_to :invoice, Invoice
    many_to_many :taxes, Tax, join_through: "items_taxes"
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, @fields)
    |> cast_assoc(:taxes)
    |> foreign_key_constraint(:invoice_id)
    |> validate_length(:description, max: 20000)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0)
    |> validate_number(:unitary_cost, greater_than_or_equal_to: 0)
  end
end

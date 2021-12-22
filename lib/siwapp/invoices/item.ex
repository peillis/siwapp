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
    field :base_amount, :integer, virtual: true
    field :discount_amount, :integer, virtual: true
    field :net_amount, :integer, virtual: true
    field :taxes_amount, :integer, virtual: true
    field :gross_amount, :integer, virtual: true
    belongs_to :invoice, Invoice
    many_to_many :taxes, Tax, join_through: "items_taxes", join_keys: [items_id: :id, taxes_id: :id], on_replace: :delete
  end

  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, @fields)
    |> cast_assoc(:taxes)
    |> foreign_key_constraint(:invoice_id)
    |> validate_length(:description, max: 20000)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  def changeset_update_taxes(item, tax) do
    item
    |> cast(%{}, @fields)
    |> put_assoc(:taxes, tax)
  end

  def base_amount(item) do
    Map.put(item, :base_amount, item.quantity * item.unitary_cost)
  end

  def discount_amount(item) do
    Map.put(item, :discount_amount, item.base_amount * item.discount / 100)
  end

  def net_amount(item) do
    Map.put(item, :net_amount, item.base_amount - item.discount_amount)
  end

  def taxes_amount(item) do
    taxes_list_amount = for tax <- item.taxes, do: tax.value * item.net_amount / 100

    Map.put(item, :taxes_amount, taxes_list_amount)
  end

  def gross_amount(item) do
    Map.put(item, :gross_amount, item.net_amount + Enum.sum(item.taxes_amount))
  end
end

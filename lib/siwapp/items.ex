defmodule Siwapp.Items do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string
    field :unitary_cost, :integer, default: 0
    field :deleted_at, :utc_datetime
    belongs_to :invoices, Siwapp.Invoices
  end

  @doc false
  def changeset(items, attrs) do
    items
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

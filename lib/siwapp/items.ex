defmodule Siwapp.Items do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string, size: 20000
    field :unitary_cost, :integer, default: 0
    field :deleted_at, :utc_datetime_usec
    field :invoices_id, :integer

  end

  @doc false
  def changeset(items, attrs) do
    items
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

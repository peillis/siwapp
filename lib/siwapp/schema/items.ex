defmodule Siwapp.Schema.Items do
  use Ecto.Schema
  alias Siwapp.Schema.Invoices
  import Ecto.Changeset

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string
    field :unitary_cost, :integer, default: 0
    field :deleted_at, :utc_datetime
    belongs_to :invoices, Invoices
  end

  @doc false
  def changeset(items, attrs) do
    items
    |> cast(attrs, [:quantity, :discount, :description, :unitary_cost, :deleted_at])
  end
end

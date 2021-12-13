defmodule Siwapp.Schema.Taxes do
  use Ecto.Schema
  alias Siwapp.Schema.Items
  import Ecto.Changeset

  schema "taxes" do
    field :name, :string
    field :value, :integer
    field :active, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
    many_to_many :items, Items, join_through: "items_taxes"
  end

  @doc false
  def changeset(taxes, attrs) do
    taxes
    |> cast(attrs, [:name, :value])
    |> validate_required([:name, :value])
  end
end

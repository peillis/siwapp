defmodule Siwapp.Schema.Tax do
  use Ecto.Schema
  alias Siwapp.Schema.Item
  import Ecto.Changeset

  schema "taxes" do
    field :name, :string
    field :value, :integer
    field :active, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
    many_to_many :items, Item, join_through: "items_taxes"
  end

  @doc false
  def changeset(taxes, attrs) do
    keys = Map.keys(attrs)

    taxes
    |> cast(attrs, keys)
    |> validate_required([:name, :value])
  end
end

defmodule Siwapp.ItemsTaxes do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "items_taxes" do
    belongs_to :items, Siwapp.Items
    belongs_to :taxes, Siwapp.Taxes

  end

  @doc false
  def changeset(items_taxes, attrs) do
    items_taxes
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

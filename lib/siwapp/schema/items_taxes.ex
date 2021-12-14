defmodule Siwapp.Schema.ItemsTaxes do
  use Ecto.Schema
  alias Siwapp.Schema.Items
  alias Siwapp.Schema.Taxes
  # import Ecto.Changeset

  @primary_key false
  schema "items_taxes" do
    belongs_to :items, Items
    belongs_to :taxes, Taxes
  end

  # @doc false
  # def changeset(items_taxes, attrs) do
  #   items_taxes
  #   |> cast(attrs, [:items_id, :taxes_id])
  # end
end

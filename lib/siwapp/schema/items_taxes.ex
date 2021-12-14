defmodule Siwapp.Schema.ItemsTaxes do
  use Ecto.Schema
  alias Siwapp.Schema.Item
  alias Siwapp.Schema.Tax
  # import Ecto.Changeset

  @primary_key false
  schema "items_taxes" do
    belongs_to :items, Item
    belongs_to :taxes, Tax
  end

  # @doc false
  # def changeset(items_taxes, attrs) do
  #   items_taxes
  #   |> cast(attrs, [:items_id, :taxes_id])
  # end
end

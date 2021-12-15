defmodule Siwapp.Schema.ItemsTaxes do
  use Ecto.Schema
  alias Siwapp.Schema.Item
  alias Siwapp.Schema.Tax

  @primary_key false
  schema "items_taxes" do
    belongs_to :items, Item
    belongs_to :taxes, Tax
  end
end

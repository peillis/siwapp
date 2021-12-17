defmodule Siwapp.Schema.MetaAttributes do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :key, :string
    field :value, :string
  end

  def changeset(meta_attribute, attrs) do
    meta_attribute
    |> cast(attrs, [:key, :value])
  end
end

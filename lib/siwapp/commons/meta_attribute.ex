defmodule Siwapp.Commons.MetaAttribute do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :temp_id, :string, virtual: true
    field :key, :string
    field :value, :string
  end

  def changeset(meta_attribute, attrs) do
    meta_attribute
    |> Map.put(:temp_id, meta_attribute.temp_id || attrs["temp_id"])
    |> cast(attrs, [:key, :value])
  end
end

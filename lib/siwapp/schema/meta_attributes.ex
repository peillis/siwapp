defmodule Siwapp.Schema.MetaAttributes do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true
    field :key, :string
    field :value, :string
  end

  def changeset(meta_attribute, attrs) do
    meta_attribute
    |> Map.put(:temp_id, (meta_attribute.temp_id || attrs["temp_id"]) )
    |> cast(attrs, [:key, :value, :delete])
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{ changeset | action: :delete }
    else
      changeset
    end
  end

end

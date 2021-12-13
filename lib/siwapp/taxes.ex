defmodule Siwapp.Taxes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taxes" do
    field :name, :string, size: 50
    field :value, :integer
    field :active, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime_usec

  end

  @doc false
  def changeset(taxes, attrs) do
    taxes
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

defmodule Siwapp.Taxes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taxes" do
    field :name, :string
    field :value, :integer
    field :active, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
  end

  @doc false
  def changeset(taxes, attrs) do
    taxes
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

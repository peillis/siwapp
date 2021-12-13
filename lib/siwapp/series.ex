defmodule Siwapp.Series do
  use Ecto.Schema
  import Ecto.Changeset

  schema "series" do
    field :name, :string
    field :value, :string
    field :enabled, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
    field :first_number, :integer, default: 1
  end

  @doc false
  def changeset(series, attrs) do
    series
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

defmodule Siwapp.Settings.Setting do
  use Ecto.Schema

  import Ecto.Changeset

  schema "settings" do
    field :key, :string
    field :value, :string

    timestamps()
  end

  def changeset(setting, attrs \\ %{}) do
    setting
    |> cast(attrs, [:key, :value])
    |> validate_required([:key])
  end
end

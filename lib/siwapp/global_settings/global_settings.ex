defmodule Siwapp.Schema.GlobalSetting do
  use Ecto.Schema

  import Ecto.Changeset

  schema "global_settings" do
    field :key, :string
    field :value, :string

    timestamps()
  end

  def changeset(global_setting, attrs \\ %{}) do
    global_setting
    |> cast(attrs, [:key, :value])
    |> validate_required([:key])
  end
end

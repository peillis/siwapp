defmodule Siwapp.Schema.Series do
  use Ecto.Schema
  alias Siwapp.Schema.Invoices
  import Ecto.Changeset

  schema "series" do
    field :name, :string
    field :value, :string
    field :enabled, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
    field :first_number, :integer, default: 1
    has_many :invoices, Invoices
  end

  @doc false
  def changeset(series, attrs) do
    series
    |> cast(attrs, [:name, :value, :enabled, :default, :deleted_at, :first_number])
    |> validate_required([:value])
  end
end

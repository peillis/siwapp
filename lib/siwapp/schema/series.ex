defmodule Siwapp.Schema.Series do
  use Ecto.Schema
  alias Siwapp.Schema.Invoice
  import Ecto.Changeset

  schema "series" do
    field :name, :string
    field :value, :string
    field :enabled, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
    field :first_number, :integer, default: 1
    has_many :invoices, Invoice
  end

  @doc false
  def changeset(series, attrs) do
    keys = Map.keys(attrs)

    series
    |> cast(attrs, keys)
    |> validate_required([:value])
  end
end

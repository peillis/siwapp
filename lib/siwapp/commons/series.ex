defmodule Siwapp.Schema.Series do
  use Ecto.Schema
  alias Siwapp.Schema.{Invoice, RecurringInvoice}
  import Ecto.Changeset
  @fields [:name, :value, :enabled, :default, :deleted_at, :first_number]

  schema "series" do
    field :name, :string
    field :value, :string
    field :enabled, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
    field :first_number, :integer, default: 1
    has_many :invoices, Invoice
    has_many :recurring_invoices, RecurringInvoice
  end

  def changeset(series, attrs \\ %{}) do
    series
    |> cast(attrs, @fields)
    |> validate_required([:value])
    |> validate_length(:name, max: 255)
    |> validate_length(:value, max: 255)
  end
end

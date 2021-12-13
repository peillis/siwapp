defmodule Siwapp.Schema.Customers do
  use Ecto.Schema
  alias Siwapp.Schema.Invoices
  import Ecto.Changeset

  schema "customers" do
    field :identification, :string
    field :name, :string
    field :email, :string
    field :contact_person, :string
    field :active, :boolean, default: true
    field :deleted_at, :utc_datetime
    field :invoicing_address, :string
    field :shipping_address, :string
    field :meta_attributes, :map
    has_many :invoices, Invoices

    timestamps()
  end

  @doc false
  def changeset(customers, attrs) do
    customers
    |> cast(attrs, [:name, :identification, :email, :invoicing_address, :shipping_address])
    |> validate_required([:name, :identification])
  end
end

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
    |> cast(attrs, [
      :name,
      :identification,
      :email,
      :contact_person,
      :active,
      :deleted_at,
      :invoicing_address,
      :shipping_address,
      :meta_attributes
    ])
    |> validate_required_customer_info(attrs)
    |> unique_constraint([:name, :identification])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
  end

  def validate_required_customer_info(changeset, %{name: _}) do
    changeset
    |> validate_required(:name)
  end

  def validate_required_customer_info(changeset, %{identification: _}) do
    changeset
    |> validate_required(:identification)
  end

  def validate_required_customer_info(changeset, %{name: _, identification: _}) do
    changeset
    |> validate_required([:name, :identification])
  end

  def validate_required_customer_info(changeset, _) do
    changeset
    |> add_error(:attrs, "either :name or :identification is required")
  end
end

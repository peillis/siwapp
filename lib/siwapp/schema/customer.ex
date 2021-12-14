defmodule Siwapp.Schema.Customer do
  use Ecto.Schema
  alias Siwapp.Schema.Invoice
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
    has_many :invoices, Invoice

    timestamps()
  end

  @doc false
  def changeset(customers, attrs) do
    keys = Map.keys(attrs)

    customers
    |> cast(attrs, keys)
    |> validate_required_customer_info(attrs)
    |> unique_constraint([:name, :identification])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
  end

  # def validate_customer(changeset, attrs) do

  #   case changeset do
  #     %{data: %Siwapp.Schema.Customer{name: nil}} -> changeset |> validate_required(:name)
  #     %{data: %Siwapp.Schema.Customer{identification: nil}} -> changeset |> validate_required(:identification)
  #     %{data: %Siwapp.Schema.Customer{name: nil, identification: nil}} -> changeset |> validate_required([:name, :identification])
  #     %{data: %Siwapp.Schema.Customer{name: _, identification: _}} -> changeset
  #   end

  # end

  def validate_required_customer_info(changeset, %{name: _}) do
    changeset
    |> validate_required(:name)
  end

  def validate_required_customer_info(changeset, %{identification: _}) do
    changeset
    |> validate_required(:identification)
  end

  def validate_required_customer_info(changeset, _) do
    changeset
    |> add_error(:attrs, "either :name or :identification is required")
  end
end

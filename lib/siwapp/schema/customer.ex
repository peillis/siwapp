defmodule Siwapp.Schema.Customer do
  use Ecto.Schema
  alias Siwapp.Schema.Invoice
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :name,
             :identification,
             :email,
             :contact_person,
             :active,
             :invoicing_address,
             :shipping_address
           ]}

  @fields [
    :name,
    :identification,
    :email,
    :contact_person,
    :active,
    :deleted_at,
    :invoicing_address,
    :shipping_address,
    :meta_attributes
  ]

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
  def changeset(customer, attrs \\ %{}) do
    customer
    |> cast(attrs, @fields)
    |> validate_required_customer([:name, :identification])
    |> unique_constraint(:identification)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_length(:name, max: 100)
    |> validate_length(:identification, max: 50)
    |> validate_length(:email, max: 100)
    |> validate_length(:contact_person, max: 100)
  end

  # Validates if either a name or an identification of a customer is contained either in the changeset or in the Customer struct.
  defp validate_required_customer(changeset, fields) do
    if Enum.any?(fields, &get_field(changeset, &1)) do
      changeset
    else
      add_error(changeset, hd(fields), "Either name or identification are required")
    end
  end
end

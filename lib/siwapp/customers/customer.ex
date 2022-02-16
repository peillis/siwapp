defmodule Siwapp.Customers.Customer do
  @moduledoc """
  Customer
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Siwapp.Invoices.Invoice
  alias Siwapp.RecurringInvoices.RecurringInvoice

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          name: binary | nil,
          identification: binary | nil,
          hash_id: binary | nil,
          email: binary | nil,
          contact_person: binary | nil,
          deleted_at: DateTime.t() | nil,
          invoicing_address: binary | nil,
          shipping_address: binary | nil,
          meta_attributes: map,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @derive {Jason.Encoder,
           only: [
             :name,
             :identification,
             :email,
             :contact_person,
             :invoicing_address,
             :shipping_address
           ]}

  @fields [
    :name,
    :identification,
    :hash_id,
    :email,
    :contact_person,
    :deleted_at,
    :invoicing_address,
    :shipping_address,
    :meta_attributes
  ]

  @email_regex Application.compile_env!(:siwapp, :email_regex)

  schema "customers" do
    field :identification, :string
    field :name, :string
    field :hash_id, :string
    field :email, :string
    field :contact_person, :string
    field :deleted_at, :utc_datetime
    field :invoicing_address, :string
    field :shipping_address, :string
    field :meta_attributes, :map, default: %{}
    field :total, :integer, virtual: true
    field :paid, :integer, virtual: true
    field :currencies, :any, virtual: true
    has_many :recurring_invoices, RecurringInvoice
    has_many :invoices, Invoice

    timestamps()
  end

  @doc false
  def changeset(customer, attrs \\ %{}) do
    customer
    |> cast(attrs, @fields)
    |> validate_required_customer([:name, :identification])
    |> put_hash_id()
    |> unique_constraint(:identification)
    |> unique_constraint(:hash_id)
    |> validate_format(:email, @email_regex)
    |> validate_length(:name, max: 100)
    |> validate_length(:identification, max: 50)
    |> validate_length(:email, max: 100)
    |> validate_length(:contact_person, max: 100)
  end

  @spec create_hash_id(binary, binary) :: binary
  def create_hash_id(identification, name) do
    :crypto.hash(:md5, "#{normalize(identification)}#{normalize(name)}") |> Base.encode16()
  end

  @spec normalize(binary) :: binary
  defp normalize(string) do
    string
    |> String.downcase()
    |> String.replace(~r/ +/, "")
  end

  # Validates if either a name or an identification is set
  defp validate_required_customer(changeset, fields) do
    if Enum.any?(fields, &get_field(changeset, &1)) do
      changeset
    else
      add_error(changeset, hd(fields), "Either name or identification are required")
    end
  end

  defp put_hash_id(changeset) do
    name = get_field_or_empty(changeset, :name)
    identification = get_field_or_empty(changeset, :identification)

    put_change(changeset, :hash_id, create_hash_id(identification, name))
  end

  defp get_field_or_empty(changeset, field) do
    get_field(changeset, field) || ""
  end
end

defmodule Siwapp.Schema.RecurringInvoice do
  use Ecto.Schema
  alias Siwapp.Schema.{Customer, Invoice, Series}
  import Ecto.Changeset

  @fields [
    :name,
    :identification,
    :email,
    :contact_person,
    :net_amount,
    :gross_amount,
    :paid_amount,
    :sent_by_email,
    :days_to_due,
    :enabled,
    :max_ocurrences,
    :min_ocurrences,
    :period,
    :period_type,
    :starting_date,
    :finishing_date,
    :failed,
    :currency,
    :deleted_at,
    :invoicing_address,
    :shipping_address,
    :notes,
    :terms,
    :meta_attributes,
    :items
  ]

  schema "recurring_invoices" do
    field :name, :string
    field :identification, :string
    field :email, :string
    field :contact_person, :string
    field :net_amount, :integer, default: 0
    field :gross_amount, :integer, default: 0
    field :paid_amount, :integer, default: 0
    field :sent_by_email, :boolean, default: false
    field :days_to_due, :integer
    field :enabled, :boolean, default: true
    field :max_ocurrences, :integer
    field :min_ocurrences, :integer
    field :period, :integer
    field :period_type, :string
    field :starting_date, :date
    field :finishing_date, :date
    field :failed, :boolean, default: false
    field :currency, :string
    field :deleted_at, :utc_datetime
    field :invoicing_address, :string
    field :shipping_address, :string
    field :notes, :string
    field :terms, :string
    field :meta_attributes, :map
    field :items, {:array, :map}
    belongs_to :customer, Customer
    belongs_to :series, Series
    has_many :invoices, Invoice

    timestamps()
  end

  @doc false
  def changeset(recurring_invoice, attrs) do
    recurring_invoice
    |> cast(attrs, @fields)
    |> validate_required_recurring_invoice([:name, :identification])
    |> validate_required([:starting_date, :period, :period_type])
    |> foreign_key_constraint(:series_id)
    |> foreign_key_constraint(:customer_id)
    |> validate_inclusion(:period_type, ["Daily", "Monthly", "Yearly"])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_length(:name, max: 100)
    |> validate_length(:identification, max: 50)
    |> validate_length(:email, max: 100)
    |> validate_length(:contact_person, max: 100)
    |> validate_length(:period_type, max: 8)
    |> validate_length(:currency, max: 3)

  end

  # Validates if either a name or a identification is contained either in the changeset or in the Recurring Invoice struct.
  defp validate_required_recurring_invoice(changeset, fields) do
    if Enum.any?(fields, &get_field(changeset, &1)) do
      changeset
    else
      add_error(changeset, hd(fields), "Either name or identification are required")
    end
  end
end

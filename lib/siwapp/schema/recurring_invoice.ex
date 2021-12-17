defmodule Siwapp.Schema.RecurringInvoice do
  use Ecto.Schema
  alias Siwapp.Schema.{Customer, Invoice, Item, Series}
  import Ecto.Changeset

  schema "recurring_invoices" do
    field :name, :string
    field :identification, :string, size: 50
    field :email, :string, size: 100
    field :contact_person, :string, size: 100
    field :net_amount, :integer, default: 0
    field :gross_amount, :integer, default: 0
    field :paid_amount, :integer, default: 0
    field :sent_by_email, :boolean, default: false
    field :days_to_due, :integer
    field :enabled, :boolean, default: true
    field :max_ocurrences, :integer
    field :min_ocurrences, :integer
    field :period, :integer
    field :period_type, :string, size: 8
    field :starting_date, :date
    field :finishing_date, :date
    field :failed, :boolean, default: false
    field :currency, :string, size: 3
    field :deleted_at, :utc_datetime
    field :invoicing_address, :text
    field :shipping_address, :text
    field :notes, :text
    field :terms, :text
    field :meta_attributes, :jsonb
    belongs_to :series, Series
    belongs_to :customer, Customer
    has_many :invoices, Invoice
    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(recurring_invoice, attrs) do
    recurring_invoice
    |> cast(attrs, [])
    |> validate_required([])
  end
end

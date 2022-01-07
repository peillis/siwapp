defmodule Siwapp.RecurringInvoices.RecurringInvoice do
  @moduledoc """
  Recurring Invoice
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Siwapp.Commons.Series
  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices.Invoice

  @fields [
    :net_amount,
    :gross_amount,
    :send_by_email,
    :days_to_due,
    :enabled,
    :max_ocurrences,
    :min_ocurrences,
    :period,
    :period_type,
    :starting_date,
    :finishing_date,
    :currency,
    :deleted_at,
    :notes,
    :terms,
    :meta_attributes,
    :items,
    :customer_id,
    :series_id
  ]

  schema "recurring_invoices" do
    field :net_amount, :integer, default: 0
    field :gross_amount, :integer, default: 0
    field :send_by_email, :boolean, default: false
    field :days_to_due, :integer
    field :enabled, :boolean, default: true
    field :max_ocurrences, :integer
    field :min_ocurrences, :integer
    field :period, :integer
    field :period_type, :string
    field :starting_date, :date
    field :finishing_date, :date
    field :currency, :string
    field :deleted_at, :utc_datetime
    field :notes, :string
    field :terms, :string
    field :meta_attributes, :map
    field :items, {:array, :map}
    belongs_to :customer, Customer
    belongs_to :series, Series
    has_many :invoices, Invoice, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(recurring_invoice, attrs) do
    recurring_invoice
    |> cast(attrs, @fields)
    |> validate_required([:starting_date, :period, :period_type])
    |> foreign_key_constraint(:series_id)
    |> foreign_key_constraint(:customer_id)
    |> validate_inclusion(:period_type, ["Daily", "Monthly", "Yearly"])
    |> validate_number(:period, greater_than_or_equal_to: 0)
    |> validate_length(:period_type, max: 8)
    |> validate_length(:currency, max: 3)
  end
end

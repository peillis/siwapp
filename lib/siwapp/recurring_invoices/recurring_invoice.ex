defmodule Siwapp.RecurringInvoices.RecurringInvoice do
  @moduledoc """
  Recurring Invoice
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Siwapp.InvoiceHelper

  alias Siwapp.Commons.Series
  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices.Invoice

  @type currency :: <<_::8, _::_*3>>
  @typedoc """
    "Monthly" | "Daily" | "Yearly"
  """
  @type period :: :binary
  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: nil | integer,
          identification: nil | String.t(),
          name: nil | String.t(),
          email: nil | String.t(),
          contact_person: nil | String.t(),
          invoicing_address: nil | String.t(),
          shipping_address: nil | String.t(),
          net_amount: integer,
          gross_amount: integer,
          send_by_email: boolean,
          days_to_due: nil | integer,
          enabled: boolean,
          max_ocurrences: nil | pos_integer,
          min_ocurrences: nil | pos_integer,
          period: nil | integer,
          period_type: nil | period,
          starting_date: nil | Date,
          finishing_date: nil | Date,
          currency: nil | currency,
          deleted_at: nil | Date,
          notes: nil | String.t(),
          terms: nil | String.t(),
          meta_attributes: nil | map,
          items: nil | [map],
          customer: Ecto.Association.NotLoaded.t() | %Siwapp.Customers.Customer{},
          series: Ecto.Association.NotLoaded.t() | [%Siwapp.Commons.Series{}],
          invoices: Ecto.Association.NotLoaded.t() | [%Siwapp.Invoices.Invoice{}],
          updated_at: nil | DateTime,
          inserted_at: nil | DateTime,
          customer_id: nil | integer,
          series_id: nil | integer
        }

  @fields [
    :name,
    :identification,
    :email,
    :contact_person,
    :invoicing_address,
    :shipping_address,
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
    field :identification, :string
    field :name, :string
    field :email, :string
    field :contact_person, :string
    field :invoicing_address, :string
    field :shipping_address, :string
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

  @spec changeset(t, map) :: Ecto.Changeset.t()
  @doc false
  def changeset(recurring_invoice, attrs) do
    recurring_invoice
    |> cast(attrs, @fields)
    |> find_customer_or_new()
    |> validate_required([:starting_date, :period, :period_type])
    |> foreign_key_constraint(:series_id)
    |> foreign_key_constraint(:customer_id)
    |> validate_inclusion(:period_type, ["Daily", "Monthly", "Yearly"])
    |> validate_number(:period, greater_than_or_equal_to: 0)
    |> validate_length(:currency, max: 3)
  end
end

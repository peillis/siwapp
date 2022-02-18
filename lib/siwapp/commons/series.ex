defmodule Siwapp.Commons.Series do
  @moduledoc """
  Series
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Siwapp.Invoices.Invoice
  alias Siwapp.RecurringInvoices.RecurringInvoice

  @derive {Jason.Encoder,
           only: [
             :default,
             :enabled,
             :first_number,
             :id,
             :name,
             :code
           ]}

  @fields [:name, :code, :enabled, :default, :deleted_at, :first_number]

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          name: binary | nil,
          code: binary | nil,
          enabled: boolean(),
          default: boolean(),
          first_number: pos_integer() | nil,
          deleted_at: DateTime.t() | nil
        }

  schema "series" do
    field :name, :string
    field :code, :string
    field :enabled, :boolean, default: true
    field :default, :boolean, default: false
    field :deleted_at, :utc_datetime
    field :first_number, :integer, default: 1
    has_many :invoices, Invoice
    has_many :recurring_invoices, RecurringInvoice
  end

  @spec changeset(t(), map) :: Ecto.Changeset.t()
  def changeset(series, attrs \\ %{}) do
    series
    |> cast(attrs, @fields)
    |> validate_required([:code])
    |> validate_length(:name, max: 255)
    |> validate_length(:code, max: 255)
  end
end

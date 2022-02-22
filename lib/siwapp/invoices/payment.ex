defmodule Siwapp.Invoices.Payment do
  @moduledoc """
  Payment
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Siwapp.Invoices.Invoice

  @fields [
    :date,
    :amount,
    :notes,
    :deleted_at,
    :invoice_id
  ]

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          amount: pos_integer(),
          notes: binary() | nil,
          updated_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil,
          deleted_at: DateTime.t() | nil,
          invoice_id: pos_integer() | nil
        }

  schema "payments" do
    field :date, :date
    field :amount, :integer
    field :notes, :string
    field :deleted_at, :utc_datetime
    belongs_to :invoice, Invoice

    timestamps()
  end

  @spec changeset(t(), map) :: Ecto.Changeset.t()
  def changeset(payment, attrs \\ %{}) do
    payment
    |> cast(attrs, @fields)
    |> foreign_key_constraint(:invoice_id)
  end
end

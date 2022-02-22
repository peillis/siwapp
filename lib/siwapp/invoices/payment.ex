defmodule Siwapp.Invoices.Payment do
  @moduledoc """
  Payment
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Siwapp.Invoices.Invoice
  alias SiwappWeb.PageView

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
    field :amount, :integer, default: 0
    field :notes, :string
    field :deleted_at, :utc_datetime
    field :virtual_amount, :float, virtual: true, default: 0.0
    belongs_to :invoice, Invoice

    timestamps()
  end

  @spec changeset(t(), map) :: Ecto.Changeset.t()
  def changeset(payment, attrs \\ %{}, currency) do
    payment
    |> cast(attrs, @fields)
    |> assign_date()
    |> set_amount(attrs, currency)
    |> foreign_key_constraint(:invoice_id)
    |> set_virtual_amount(currency)
  end

  @spec assign_date(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp assign_date(changeset) do
    if get_field(changeset, :date) do
      changeset
    else
      put_change(changeset, :date, Date.utc_today())
    end
  end

  @spec set_amount(Ecto.Changeset.t(), map, atom() | binary()) :: Ecto.Changeset.t()
  def set_amount(changeset, attrs, currency) do
    virtual_amount =
      Map.get(attrs, :virtual_amount) || Map.get(attrs, "virtual_amount")

    cond do
      is_nil(virtual_amount) ->
        changeset

      virtual_amount == "" ->
        put_change(changeset, :amount, 0)

      true ->
        case Money.parse(virtual_amount, currency) do
          {:ok, %Money{amount: amount}} -> put_change(changeset, :amount, amount)
          :error -> add_error(changeset, :virtual_amount, "Invalid format")
        end
    end
  end

  @spec set_virtual_amount(Ecto.Changeset.t(), atom() | binary()) :: Ecto.Changeset.t()
  def set_virtual_amount(changeset, currency) do
    if is_nil(get_field(changeset, :amount)) do
      changeset
    else
      amount = get_field(changeset, :amount)

      virtual_amount =
        PageView.money_format(amount, currency, symbol: false, separator: "")

      put_change(changeset, :virtual_amount, virtual_amount)
    end
  end
end

defmodule Siwapp.Invoices.Item do
  @moduledoc """
  Item
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Siwapp.Invoices.AmountHelper

  alias Siwapp.Commons
  alias Siwapp.Commons.Tax
  alias Siwapp.Invoices.Invoice

  @fields [
    :quantity,
    :discount,
    :description,
    :unitary_cost,
    :invoice_id,
    :virtual_unitary_cost
  ]

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          quantity: pos_integer(),
          discount: non_neg_integer(),
          description: binary() | nil,
          unitary_cost: integer(),
          invoice_id: pos_integer() | nil
        }

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string
    field :unitary_cost, :integer, default: 0
    field :net_amount, :integer, virtual: true, default: 0
    field :taxes_amount, :map, virtual: true, default: %{}
    field :virtual_unitary_cost, :decimal, virtual: true
    belongs_to :invoice, Invoice

    many_to_many :taxes, Tax,
      join_through: "items_taxes",
      on_replace: :delete
  end

  @spec changeset(t(), map, binary | atom) :: Ecto.Changeset.t()
  def changeset(item, attrs \\ %{}, currency) do
    item
    |> cast(attrs, @fields)
    |> set_amount(:unitary_cost, :virtual_unitary_cost, currency)
    |> assoc_taxes(attrs)
    |> foreign_key_constraint(:invoice_id)
    |> validate_length(:description, max: 20_000)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> calculate()
  end

  @doc """
  Performs the totals calculations for net_amount and taxes_amount fields.
  """
  @spec calculate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def calculate(changeset) do
    changeset
    |> set_net_amount()
    |> set_taxes_amount()
  end

  @spec set_net_amount(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp set_net_amount(changeset) do
    quantity = get_field(changeset, :quantity)
    unitary_cost = get_field(changeset, :unitary_cost)
    discount = get_field(changeset, :discount)

    net_amount = round(quantity * unitary_cost * (1 - discount / 100))

    put_change(changeset, :net_amount, net_amount)
  end

  @spec set_taxes_amount(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp set_taxes_amount(changeset) do
    case get_field(changeset, :taxes) do
      [] ->
        changeset

      taxes ->
        net_amount = get_field(changeset, :net_amount)

        taxes_amounts =
          for tax <- taxes, into: %{} do
            tax_val = Decimal.new("#{tax.value / 100}")
            {tax.name, Decimal.mult(net_amount, tax_val)}
          end

        put_change(changeset, :taxes_amount, taxes_amounts)
    end
  end

  # First, we check that the taxes association doesn't exist, because if it does
  # we cast it and that's it. If it actually doesn't, we find the taxes associated
  # in the attributes. If the attributes have a tax that it doesn't exist we add
  # an error in the changeset.

  @spec assoc_taxes(Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  defp assoc_taxes(changeset, attrs) do
    attr_taxes = Map.get(attrs, :taxes) || Map.get(attrs, "taxes")

    cond do
      attr_taxes -> find_taxes(changeset, attr_taxes)
      get_field(changeset, :taxes) != [] -> cast_assoc(changeset, :taxes)
      true -> find_taxes(changeset, [])
    end
  end

  @spec find_taxes(Ecto.Changeset.t(), [binary()]) :: Ecto.Changeset.t()
  defp find_taxes(changeset, attr_taxes_names) do
    all_taxes = Commons.list_taxes(:cache)
    all_taxes_names = Enum.map(all_taxes, &String.upcase(&1.name))

    attr_taxes_names = Enum.map(attr_taxes_names, &String.upcase/1)
    attr_taxes = Enum.filter(all_taxes, &(String.upcase(&1.name) in attr_taxes_names))

    attr_taxes_names
    |> Enum.reduce(changeset, &check_wrong_taxes(&1, &2, all_taxes_names))
    |> put_assoc(:taxes, attr_taxes)
  end

  @spec check_wrong_taxes(String.t(), Ecto.Changeset.t(), [String.t()]) :: Ecto.Changeset.t()
  defp check_wrong_taxes(tax, changeset, taxes) do
    if Enum.member?(taxes, tax) do
      changeset
    else
      add_error(changeset, :taxes, "The tax #{tax} is not defined")
    end
  end
end

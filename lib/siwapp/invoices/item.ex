defmodule Siwapp.Invoices.Item do
  @moduledoc """
  Item
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Siwapp.Commons
  alias Siwapp.Commons.Tax
  alias Siwapp.Invoices.Invoice

  @type t :: %__MODULE__{
          id: pos_integer(),
          quantity: pos_integer(),
          discount: non_neg_integer(),
          description: binary() | nil,
          unitary_cost: integer(),
          deleted_at: DateTime.t() | nil,
          invoice_id: pos_integer() | nil
        }
  @derive {Jason.Encoder,
           only: [
             :quantity,
             :discount,
             :description,
             :unitary_cost,
             :deleted_at,
             :invoice_id
           ]}

  @fields [
    :quantity,
    :discount,
    :description,
    :unitary_cost,
    :deleted_at,
    :invoice_id
  ]

  schema "items" do
    field :quantity, :integer, default: 1
    field :discount, :integer, default: 0
    field :description, :string
    field :unitary_cost, :integer, default: 0
    field :deleted_at, :utc_datetime
    field :net_amount, :float, virtual: true, default: 0.0
    field :taxes_amount, :map, virtual: true, default: %{}
    belongs_to :invoice, Invoice

    many_to_many :taxes, Tax,
      join_through: "items_taxes",
      on_replace: :delete
  end

  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, @fields)
    |> find_taxes(attrs)
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

  defp set_net_amount(changeset) do
    quantity = get_field(changeset, :quantity)
    unitary_cost = get_field(changeset, :unitary_cost)
    discount = get_field(changeset, :discount)

    net_amount = quantity * unitary_cost - quantity * unitary_cost * discount / 100

    put_change(changeset, :net_amount, net_amount)
  end

  defp set_taxes_amount(changeset) do
    case get_field(changeset, :taxes) do
      [] ->
        changeset

      taxes ->
        net_amount = get_field(changeset, :net_amount)

        taxes_amounts =
          for tax <- taxes, into: %{} do
            {tax.name, net_amount * (tax.value / 100)}
          end

        put_change(changeset, :taxes_amount, taxes_amounts)
    end
  end

  # First, we check if there is no taxes in data or there it is but we have
  # new taxes from attributes to add. If there is taxes association, we simply
  # cast it.

  defp find_taxes(changeset, attrs) do
    taxes_from_data = get_field(changeset, :taxes)

    taxes_from_attrs =
      (Map.get(attrs, :taxes) || Map.get(attrs, "taxes", []))
      |> Enum.map(&if is_map(&1), do: &1.name, else: &1)
      |> Enum.map(&String.downcase/1)

    if taxes_from_data == [] or taxes_from_attrs != [] do
      add_tax_assoc(changeset, taxes_from_attrs)
    else
      cast_assoc(changeset, :taxes)
    end
  end

  defp add_tax_assoc(changeset, taxes) do
    list_taxes = Commons.list_taxes()
    taxes_assoc = Enum.filter(list_taxes, &(String.downcase(&1.name) in taxes))
    database_taxes = Enum.map(list_taxes, &String.downcase(&1.name))

    Enum.reduce(taxes, changeset, fn tax, acc_changeset ->
      check_wrong_taxes(tax, acc_changeset, database_taxes)
    end)
    |> put_assoc(:taxes, taxes_assoc)
  end

  defp check_wrong_taxes(tax, changeset, database_taxes) do
    if Enum.member?(database_taxes, tax) do
      changeset
    else
      add_error(changeset, :taxes, "The tax #{String.upcase(tax)} is not defined")
    end
  end
end

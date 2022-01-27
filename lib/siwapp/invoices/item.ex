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
    field :virtual_unitary_cost, :float, virtual: true, default: 0.0
    belongs_to :invoice, Invoice

    many_to_many :taxes, Tax,
      join_through: "items_taxes",
      on_replace: :delete
  end

  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, @fields)
    |> set_unitary_cost(attrs)
    |> find_taxes(attrs)
    |> foreign_key_constraint(:invoice_id)
    |> validate_length(:description, max: 20_000)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> calculate()
    |> set_virtual_unitary_cost()
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

  # First, we check that the taxes association doesn't exist, because if it does
  # we cast it and that's it. If it actually doesn't, we find the taxes associated
  # in the attributes. If the attributes have a tax that it doesn't exist we add
  # an error in the changeset.

  defp find_taxes(changeset, attrs) do
    if get_field(changeset, :taxes) == [] do
      taxes =
        (Map.get(attrs, :taxes) || Map.get(attrs, "taxes", []))
        |> Enum.map(&String.downcase/1)

      list_taxes = Commons.list_taxes()
      taxes_assoc = Enum.filter(list_taxes, &(String.downcase(&1.name) in taxes))
      database_taxes = Enum.map(list_taxes, &String.downcase(&1.name))

      Enum.reduce(taxes, changeset, fn tax, acc_changeset ->
        check_wrong_taxes(tax, acc_changeset, database_taxes)
      end)
      |> put_assoc(:taxes, taxes_assoc)
    else
      cast_assoc(changeset, :taxes)
    end
  end

  defp check_wrong_taxes(tax, changeset, database_taxes) do
    if Enum.member?(database_taxes, tax) do
      changeset
    else
      add_error(changeset, :taxes, "The tax #{String.upcase(tax)} is not defined")
    end
  end

  def set_unitary_cost(changeset, attrs) do
    unitary_cost = Map.get(attrs, :virtual_unitary_cost) || Map.get(attrs, "virtual_unitary_cost")

    cond do
      is_nil(unitary_cost) ->
        put_change(changeset, :unitary_cost, 0)

      is_float(unitary_cost) || is_integer(unitary_cost) ->
        put_change(changeset, :unitary_cost, round(unitary_cost * 100))

      is_binary(unitary_cost) ->
        case string_to_float(unitary_cost) do
          {:ok, value} -> put_change(changeset, :unitary_cost, round(value * 100))
          {:error, msg} -> add_error(changeset, :virtual_unitary_cost, msg)
        end
    end
  end

  defp string_to_float(unitary_cost) do
    cond do
      unitary_cost == "" ->
        {:ok, 0}

      String.ends_with?(unitary_cost, ".") ->
        value =
          unitary_cost
          |> String.trim(".")
          |> String.to_integer()

        {:ok, value}

      String.match?(unitary_cost, ~r/^[+-]?[0-9]*\.?[0-9]*$/) ->
        {value, _} = Float.parse(unitary_cost)
        {:ok, value}

      true ->
        {:error, "Invalid format"}
    end
  end

  def set_virtual_unitary_cost(changeset) do
    if is_nil(get_field(changeset, :unitary_cost)) do
      changeset
    else
      virtual_unitary_cost =
        :erlang.float_to_binary(get_field(changeset, :unitary_cost) / 100, decimals: 2)

      put_change(changeset, :virtual_unitary_cost, virtual_unitary_cost)
    end
  end
end

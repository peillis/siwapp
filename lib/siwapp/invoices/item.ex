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
      all_taxes = Commons.list_taxes(:cache)
      all_taxes_names = Enum.map(all_taxes, &String.upcase(&1.name))

      attr_taxes_names =
        Enum.map(Map.get(attrs, :taxes) || Map.get(attrs, "taxes", []), &String.upcase/1)

      attr_taxes = Enum.filter(all_taxes, &(String.upcase(&1.name) in attr_taxes_names))

      attr_taxes_names
      |> Enum.reduce(changeset, &check_wrong_taxes(&1, &2, all_taxes_names))
      |> put_assoc(:taxes, attr_taxes)
    else
      cast_assoc(changeset, :taxes)
    end
  end

  defp check_wrong_taxes(tax, changeset, database_taxes) do
    if Enum.member?(database_taxes, tax) do
      changeset
    else
      add_error(changeset, :taxes, "The tax #{tax} is not defined")
    end
  end

  def set_unitary_cost(changeset, attrs) do
    virtual_unitary_cost =
      Map.get(attrs, :virtual_unitary_cost) || Map.get(attrs, "virtual_unitary_cost")

    unitary_cost = get_field(changeset, :unitary_cost)
    put_change_unitary_cost(changeset, virtual_unitary_cost, unitary_cost)
  end

  defp put_change_unitary_cost(changeset, nil, nil) do
    put_change(changeset, :unitary_cost, 0)
  end

  defp put_change_unitary_cost(changeset, virtual_unitary_cost, _unitary_cost)
       when is_float(virtual_unitary_cost) or is_integer(virtual_unitary_cost) do
    put_change(changeset, :unitary_cost, round(virtual_unitary_cost * 100))
  end

  defp put_change_unitary_cost(changeset, virtual_unitary_cost, _unitary_cost)
       when is_binary(virtual_unitary_cost) do
    case string_to_float(virtual_unitary_cost) do
      {:ok, value} -> put_change(changeset, :unitary_cost, round(value * 100))
      {:error, msg} -> add_error(changeset, :virtual_unitary_cost, msg)
    end
  end

  defp put_change_unitary_cost(changeset, _virtual_unitary_cost, _unitary_cost) do
    changeset
  end

  defp string_to_float(number) do
    cond do
      number == "" ->
        {:ok, 0}

      String.ends_with?(number, ".") && String.match?(number, ~r/^[+-]?[0-9]*\.?[0-9]*$/) ->
        value =
          number
          |> String.trim(".")
          |> String.to_integer()

        {:ok, value}

      String.match?(number, ~r/^[+-]?[0-9]*\.?[0-9]*$/) ->
        {value, _} = Float.parse(number)
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

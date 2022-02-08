defmodule Siwapp.RecurringInvoices.RecurringInvoice do
  @moduledoc """
  Recurring Invoice
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Siwapp.InvoiceHelper

  alias Siwapp.Commons.Series
  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices.{Invoice, Item}

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: nil | pos_integer(),
          enabled: boolean,
          identification: nil | binary,
          name: nil | binary,
          email: nil | binary,
          contact_person: nil | binary,
          invoicing_address: nil | binary,
          shipping_address: nil | binary,
          net_amount: integer,
          gross_amount: integer,
          notes: nil | binary,
          terms: nil | binary,
          meta_attributes: nil | map,
          customer_id: nil | pos_integer(),
          series_id: nil | pos_integer(),
          currency: nil | <<_::24>>,
          days_to_due: nil | integer,
          items: nil | [map],
          send_by_email: boolean,
          max_ocurrences: nil | pos_integer(),
          period: nil | pos_integer,
          period_type: nil | binary,
          starting_date: nil | Date.t(),
          finishing_date: nil | Date.t(),
          customer: Ecto.Association.NotLoaded.t() | Customer.t(),
          series: Ecto.Association.NotLoaded.t() | [Series.t()],
          invoices: Ecto.Association.NotLoaded.t() | [Invoice.t()],
          updated_at: nil | DateTime.t(),
          inserted_at: nil | DateTime.t(),
          deleted_at: nil | Date.t()
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
    :series_id,
    :save?
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
    field :taxes_amounts, :map, virtual: true, default: %{}
    field :max_ocurrences, :integer
    field :period, :integer
    field :period_type, :string
    field :starting_date, :date
    field :finishing_date, :date
    field :currency, :string
    field :deleted_at, :utc_datetime
    field :notes, :string
    field :terms, :string
    field :meta_attributes, :map, default: %{}
    field :items, {:array, :map}, default: []
    belongs_to :customer, Customer, on_replace: :nilify
    belongs_to :series, Series
    has_many :invoices, Invoice, on_replace: :delete

    timestamps()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  @doc false
  def changeset(recurring_invoice, attrs) do
    recurring_invoice
    |> cast(attrs, @fields)
    |> maybe_find_customer_or_new()
    |> transform_items()
    |> validate_items()
    |> calculate()
    |> adequate_items()
    |> validate_required([:starting_date, :period, :period_type])
    |> foreign_key_constraint(:series_id)
    |> foreign_key_constraint(:customer_id)
    |> validate_inclusion(:period_type, ["Daily", "Monthly", "Yearly"])
    |> validate_number(:period, greater_than_or_equal_to: 0)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_length(:name, max: 100)
    |> validate_length(:identification, max: 50)
    |> validate_length(:email, max: 100)
    |> validate_length(:contact_person, max: 100)
    |> validate_length(:currency, max: 3)
  end

<<<<<<< HEAD
  # Performs the totals calculations for net_amount, taxes_amounts and gross_amount fields.
  defp calculate(changeset) do
    changeset
    |> set_net_amount()
    |> set_taxes_amounts()
    |> set_gross_amount()
  end

  defp set_net_amount(changeset) do
    total_net_amount =
      get_field(changeset, :items_transformed)
      |> Enum.map(&get_field(&1, :net_amount))
      |> Enum.sum()
      |> round()
=======
  @doc """
  Converts field items from list of Item changesets to list of maps when
  changeset is valid to be able to save in database
  """
  def untransform_items(%{valid?: true} = changeset) do
    items =
      get_field(changeset, :items)
      |> Enum.map(&apply_changes(&1))
      |> Enum.map(&make_item(&1))

    put_change(changeset, :items, items)
  end

  def untransform_items(changeset), do: changeset

  # Converts field items from list of maps to list of Item changesets.
  # This is used to handle items validation and calculations
  defp transform_items(changeset) do
    items_transformed =
      get_field(changeset, :items)
      |> Enum.map(&Item.changeset(%Item{}, &1))
>>>>>>> ba1245d (Fn changeset única, documentación y comentarios)

    put_change(changeset, :net_amount, total_net_amount)
  end

<<<<<<< HEAD
  defp set_taxes_amounts(changeset) do
    total_taxes_amounts =
      get_field(changeset, :items_transformed)
      |> Enum.map(&get_field(&1, :taxes_amount))
      |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _, v1, v2 -> v1 + v2 end))

    put_change(changeset, :taxes_amounts, total_taxes_amounts)
  end

  defp set_gross_amount(changeset) do
    net_amount = get_field(changeset, :net_amount)

    taxes_amount =
      get_field(changeset, :taxes_amounts)
      |> Map.values()
      |> Enum.sum()
=======
  # Adds error to changeset if any item is invalid
  defp validate_items(changeset) do
    items_valid? =
      get_field(changeset, :items)
      |> Enum.all?(& &1.valid?)

    if items_valid? do
      changeset
    else
      add_error(changeset, :items, "Items are invalid")
    end
  end

  # Applies changes (builds Item struct) to each Item changeset in field items.
  # Used to recycle calculate functions in invoice_helper, that use Item structs
  defp apply_changes_items(changeset) do
    items =
      get_field(changeset, :items)
      |> Enum.map(&apply_changes(&1))
>>>>>>> ba1245d (Fn changeset única, documentación y comentarios)

    put_change(changeset, :gross_amount, round(net_amount + taxes_amount))
  end

<<<<<<< HEAD
  defp transform_items(changeset) do
    items_transformed =
=======
  # Converts each Item struct in a changeset (changing empty map).
  # Used to recycle add_item, remove_item functions in views and
  # build item forms' for user to fill
  defp unapply_changes_items(changeset) do
    items =
>>>>>>> ba1245d (Fn changeset única, documentación y comentarios)
      get_field(changeset, :items)
      |> Enum.map(&Item.changeset(%Item{}, &1))

    put_change(changeset, :items_transformed, items_transformed)
  end

<<<<<<< HEAD
  defp validate_items(changeset) do
    items_valid? =
      get_field(changeset, :items_transformed)
      |> Enum.all?(& &1.valid?)

    if items_valid? do
      changeset
    else
      add_error(changeset, :items, "Items are invalid")
    end
  end

  defp adequate_items(%{changes: %{save?: true}} = changeset) do
    items_zip = Enum.zip(get_field(changeset, :items), get_field(changeset, :items_transformed))

    items =
      Enum.map(items_zip, fn {item, item_changeset} ->
        item_virtual_to_unitary(item, item_changeset)
      end)

    put_change(changeset, :items, items)
=======
  defp make_item(%Item{description: d, quantity: q, unitary_cost: u, discount: di, taxes: t}) do
    %{
      "description" => d,
      "quantity" => q,
      "unitary_cost" => u,
      "discount" => di,
      "taxes" => Enum.map(t, & &1.name)
    }
>>>>>>> ba1245d (Fn changeset única, documentación y comentarios)
  end

  defp adequate_items(changeset), do: changeset

  @spec item_virtual_to_unitary(map, Ecto.Changeset.t()) :: map
  defp item_virtual_to_unitary(item, item_changeset),
    do:
      item
      |> Map.delete("virtual_unitary_cost")
      |> Map.put("unitary_cost", "#{get_field(item_changeset, :unitary_cost)}")
end

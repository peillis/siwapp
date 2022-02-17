defmodule Siwapp.Invoices.Invoice do
  @moduledoc """
  Invoice
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Siwapp.InvoiceHelper

  alias Siwapp.Commons.Series
  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices.{InvoiceQuery, Item}
  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Repo

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: pos_integer() | nil,
          recurring_invoice_id: pos_integer() | nil,
          name: binary() | nil,
          identification: binary() | nil,
          email: binary() | nil,
          contact_person: binary() | nil,
          invoicing_address: binary() | nil,
          shipping_address: binary() | nil,
          net_amount: non_neg_integer(),
          gross_amount: non_neg_integer(),
          notes: binary() | nil,
          terms: binary() | nil,
          meta_attributes: map() | nil,
          customer_id: pos_integer() | nil,
          series_id: pos_integer() | nil,
          currency: <<_::24>> | nil,
          due_date: Date.t() | nil,
          items: Ecto.Association.NotLoaded.t() | [Item.t()],
          sent_by_email: boolean(),
          paid_amount: non_neg_integer(),
          draft: boolean(),
          paid: boolean(),
          failed: boolean(),
          number: pos_integer() | nil,
          issue_date: Date.t() | nil,
          customer: Ecto.Association.NotLoaded.t() | Customer.t(),
          series: Ecto.Association.NotLoaded.t() | Series.t(),
          updated_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil,
          deleted_at: DateTime.t() | nil
        }

  @fields [
    :name,
    :identification,
    :email,
    :contact_person,
    :net_amount,
    :gross_amount,
    :paid_amount,
    :draft,
    :paid,
    :sent_by_email,
    :number,
    :issue_date,
    :due_date,
    :failed,
    :currency,
    :invoicing_address,
    :shipping_address,
    :notes,
    :terms,
    :deleted_at,
    :meta_attributes,
    :series_id,
    :customer_id,
    :recurring_invoice_id
  ]

  @email_regex Application.compile_env!(:siwapp, :email_regex)

  schema "invoices" do
    field :identification, :string
    field :name, :string
    field :email, :string
    field :contact_person, :string
    field :net_amount, :integer, default: 0
    field :gross_amount, :integer, default: 0
    field :paid_amount, :integer, default: 0
    field :taxes_amounts, :map, virtual: true, default: %{}
    field :draft, :boolean, default: false
    field :paid, :boolean, default: false
    field :sent_by_email, :boolean, default: false
    field :number, :integer
    field :issue_date, :date
    field :due_date, :date
    field :failed, :boolean, default: false
    field :currency, :string
    field :invoicing_address, :string
    field :shipping_address, :string
    field :notes, :string
    field :terms, :string
    field :deleted_at, :utc_datetime
    field :meta_attributes, :map, default: %{}
    belongs_to :series, Series
    belongs_to :customer, Customer, on_replace: :nilify
    belongs_to :recurring_invoice, RecurringInvoice
    has_many :items, Item, on_replace: :delete

    timestamps()
  end

  @spec changeset(t(), map) :: Ecto.Changeset.t()
  def changeset(invoice, attrs \\ %{}) do
    invoice
    |> cast(attrs, @fields)
    |> cast_assoc(:items)
    |> assign_currency()
    |> assign_issue_date()
    |> assign_due_date()
    |> only_new_invoice_can_be_draft()
    |> validate_required_draft()
    |> validate_draft_has_not_number()
    |> unique_constraint([:series_id, :number])
    |> foreign_key_constraint(:series_id)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:recurring_invoice_id)
    |> validate_format(:email, @email_regex)
    |> validate_length(:name, max: 100)
    |> validate_length(:identification, max: 50)
    |> validate_length(:email, max: 100)
    |> validate_length(:contact_person, max: 100)
    |> validate_length(:currency, max: 3)
    |> calculate()
  end

  @doc """
  Assigns the series next number to the invoice changeset.
  """
  @spec assign_number(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def assign_number(changeset) do
    cond do
      # It's illegal to assign a number to a draft
      get_field(changeset, :draft) ->
        changeset

      is_nil(get_change(changeset, :series_id)) ->
        changeset

      is_nil(get_change(changeset, :number)) ->
        next_number =
          changeset
          |> get_field(:series_id)
          |> next_number_in_series()

        put_change(changeset, :number, next_number)

      true ->
        changeset
    end
  end

  @spec assign_issue_date(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp assign_issue_date(changeset) do
    if get_field(changeset, :issue_date) do
      changeset
    else
      put_change(changeset, :issue_date, Date.utc_today())
    end
  end

  @spec assign_due_date(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp assign_due_date(changeset) do
    if get_field(changeset, :due_date) do
      changeset
    else
      issue_date = get_field(changeset, :issue_date)
      days_to_due = Siwapp.Settings.value(:days_to_due, :cache)
      due_date = Date.add(issue_date, String.to_integer(days_to_due))
      put_change(changeset, :due_date, due_date)
    end
  end

  # you can't convert an existing invoice to draft
  @spec only_new_invoice_can_be_draft(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp only_new_invoice_can_be_draft(changeset) do
    if get_field(changeset, :id) != nil and
         get_change(changeset, :draft) == true do
      add_error(changeset, :draft, "can't be enabled, invoice is not new")
    else
      changeset
    end
  end

  # When draft there are few restrictions
  @spec validate_required_draft(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_required_draft(changeset) do
    if get_field(changeset, :draft) do
      changeset
    else
      changeset
      |> validate_required([:series_id, :issue_date])
      |> assoc_constraint(:customer)
    end
  end

  # Draft can't have number
  @spec validate_draft_has_not_number(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_draft_has_not_number(changeset) do
    if get_field(changeset, :draft) and get_field(changeset, :number) do
      add_error(changeset, :number, "can't assign number to draft")
    else
      changeset
    end
  end

  @spec next_number_in_series(pos_integer()) :: integer
  defp next_number_in_series(series_id) do
    query = InvoiceQuery.last_number_with_series_id(__MODULE__, series_id)

    case Repo.one(query) do
      nil -> Repo.get(Series, series_id).first_number
      invoice -> invoice.number + 1
    end
  end
end

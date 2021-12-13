defmodule Siwapp.Invoices do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :identification, :string
    field :name, :string
    field :email, :string
    field :contact_person, :string
    field :net_amount, :integer, default: 0
    field :gross_amount, :integer, default: 0
    field :paid_amount, :integer, default: 0
    field :draft, :boolean, default: false
    field :paid, :boolean, default: false
    field :sent_by_email, :boolean, default: false
    field :number, :integer
    field :issue_date, :date
    field :due_date, :date
    field :failed, :boolean, default: false
    field :deleted_number, :integer
    field :currency, :string
    field :invoicing_address, :string
    field :shipping_address, :string
    field :notes, :string
    field :terms, :string
    field :deleted_at, :utc_datetime
    field :meta_attributes, :map
    belongs_to :series, Siwapp.Series
    belongs_to :customers, Siwapp.Customers

    timestamps()
  end

  @doc false
  def changeset(invoices, attrs) do
    invoices
    |> cast(attrs, [
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
      :deleted_number,
      :currency,
      :invoicing_address,
      :shipping_address,
      :notes,
      :terms,
      :deleted_at,
      :meta_attributes,
      :series_id,
      :customers_id])
    |> validate_name()
  end

  def validate_name(changeset) do
    changeset
    |> validate_required([:name])
  end

  def validate_identification(changeset) do
    changeset
    |> validate_required([:identification])
    |> unique_constraint(:email)
  end

  def validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "email must have the @ sign and no spaces")
    |> unique_constraint(:email)
  end

end

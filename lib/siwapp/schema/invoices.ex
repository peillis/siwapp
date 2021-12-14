defmodule Siwapp.Schema.Invoices do
  use Ecto.Schema
  alias Siwapp.Schema.Series
  alias Siwapp.Schema.Customers
  alias Siwapp.Schema.Items
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
    belongs_to :series, Series
    belongs_to :customers, Customers
    has_many :items, Items

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
      :meta_attributes
    ])
    |> validate_required_customer_info(attrs)
    |> foreign_key_constraint(:series_id)
    |> foreign_key_constraint(:customers_id)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> unique_constraint(:number)
  end

  def validate_required_customer_info(changeset, %{name: _}) do
    changeset
    |> validate_required(:name)
  end

  def validate_required_customer_info(changeset, %{identification: _}) do
    changeset
    |> validate_required(:identification)
  end

  def validate_required_customer_info(changeset, %{name: _, identification: _}) do
    changeset
    |> validate_required([:name, :identification])
  end

  def validate_required_customer_info(changeset, _) do
    changeset
    |> add_error(:attrs, "either :name or :identification is required")
  end
end

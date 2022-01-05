defmodule Siwapp.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:series) do
      add :name, :string, size: 255
      add :value, :string, size: 255
      add :enabled, :boolean, default: true
      add :default, :boolean, default: false
      add :deleted_at, :utc_datetime
      add :first_number, :integer, default: 1
    end

    create table(:customers) do
      add :name, :string, size: 100
      add :identification, :string, size: 50
      add :hash_id, :string, size: 32
      add :email, :string, size: 100
      add :contact_person, :string, size: 100
      add :deleted_at, :utc_datetime
      add :active, :boolean, default: true
      add :invoicing_address, :text
      add :shipping_address, :text
      add :meta_attributes, :jsonb

      timestamps()
    end

    create index(:customers, [:identification], unique: true)
    create index(:customers, [:hash_id], unique: true)

    create table(:invoices) do
      add :name, :string, size: 100
      add :identification, :string, size: 50
      add :email, :string, size: 100
      add :contact_person, :string, size: 100
      add :net_amount, :integer, default: 0
      add :gross_amount, :integer, default: 0
      add :paid_amount, :integer, default: 0
      add :draft, :boolean, default: false
      add :paid, :boolean, default: false
      add :sent_by_email, :boolean, default: false
      add :number, :integer
      add :issue_date, :date
      add :due_date, :date
      add :failed, :boolean, default: false
      add :deleted_number, :integer
      add :currency, :string, size: 3
      add :deleted_at, :utc_datetime
      add :invoicing_address, :text
      add :shipping_address, :text
      add :notes, :text
      add :terms, :text
      add :meta_attributes, :jsonb
      add :series_id, references(:series, type: :integer)
      add :customer_id, references(:customers, type: :integer), null: false

      timestamps()
    end

    create index(:invoices, [:contact_person])
    create index(:invoices, [:identification])
    create index(:invoices, [:email])
    create index(:invoices, [:name])
    create index(:invoices, [:series_id, :number], unique: true)
    create index(:invoices, [:series_id, :deleted_number], unique: true)
    create index(:invoices, [:customer_id])
    create index(:invoices, [:series_id])

    create table(:items) do
      add :quantity, :integer, default: 1
      add :discount, :integer, default: 0
      add :description, :string, size: 20000
      add :unitary_cost, :integer, default: 0
      add :deleted_at, :utc_datetime
      add :invoice_id, references(:invoices, type: :integer)
    end

    create index(:items, [:description])
    create index(:items, [:invoice_id])

    create table(:taxes) do
      add :name, :string, size: 50
      add :value, :integer
      add :enabled, :boolean, default: true
      add :default, :boolean, default: false
      add :deleted_at, :utc_datetime
    end

    create index(:taxes, [:name, :enabled], unique: true)

    create table(:items_taxes, primary_key: false) do
      add :item_id, references(:items, on_delete: :delete_all)
      add :tax_id, references(:taxes, on_delete: :delete_all)
    end

    create table(:templates) do
      add :name, :string, size: 255
      add :template, :text
      add :print_default, :boolean, default: false
      add :email_default, :boolean, default: false
      add :subject, :string, size: 200
      add :deleted_at, :utc_datetime

      timestamps()
    end
  end
end

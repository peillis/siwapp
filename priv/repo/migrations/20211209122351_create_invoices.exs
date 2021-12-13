defmodule Siwapp.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
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
      add :deleted_at, :utc_datetime_usec

      timestamps()
    end

    execute("CREATE INDEX cntct_idx ON invoices(contact_person)")
    execute("CREATE INDEX cstid_idx ON invoices(identification)")
    execute("CREATE INDEX cstml_idx ON invoices(email)")
    execute("CREATE INDEX cstnm_idx ON invoices(name)")
    execute("CREATE INDEX index_invoices_on_deleted_at ON invoices(deleted_at)")

    create table(:series) do
      add :name, :string, size: 255
      add :value, :string, size: 255
      add :enabled, :boolean, default: true
      add :default, :boolean, default: false
      add :deleted_at, :utc_datetime_usec
      add :first_number, :integer, default: 1
    end

    execute("CREATE INDEX index_series_on_deleted_at ON series(deleted_at)")

    create table(:customers) do
      add :name, :string, size: 100
      add :name_slug, :string, size: 100
      add :identification, :string, size: 50
      add :email, :string, sie: 100
      add :contact_person, :string, size: 100
      add :deleted_at, :utc_datetime_usec
      add :active, :boolean, default: true
    end

    execute("CREATE UNIQUE INDEX cstm_slug_idx ON customers(name_slug)")
    execute("CREATE INDEX index_customers_on_deleted_at ON customers(deleted_at)")

    create table(:items) do
      add :quantity, :integer, default: 1
      add :discount, :integer, default: 0
      add :description, :string, size: 20000
      add :unitary_cost, :integer, default: 0
      add :deleted_at, :utc_datetime_usec
    end

    execute("CREATE INDEX desc_idx ON items(description)")
    execute("CREATE INDEX index_items_on_deleted_at ON items(deleted_at)")

    create table(:taxes) do
      add :name, :string, size: 50
      add :value, :integer
      add :active, :boolean, default: true
      add :default, :boolean, default: false
      add :deleted_at, :utc_datetime_usec
    end

    execute("CREATE INDEX index_taxes_on_deleted_at ON taxes(deleted_at)")

    create table(:items_taxes, primary_key: false) do
      add :item_id, references(:items)
      add :tax_id, references(:taxes)
    end
  end
end

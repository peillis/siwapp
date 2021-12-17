defmodule Siwapp.Repo.Migrations.CreateRecurringInvoices do
  use Ecto.Migration

  def change do
    create table(:recurring_invoices) do
      add :net_amount, :integer, default: 0
      add :gross_amount, :integer, default: 0
      add :paid_amount, :integer, default: 0
      add :sent_by_email, :boolean, default: false
      add :days_to_due, :integer
      add :enabled, :boolean, default: true
      add :max_ocurrences, :integer
      add :min_ocurrences, :integer
      add :period, :integer
      add :period_type, :string, size: 8
      add :starting_date, :date
      add :finishing_date, :date
      add :failed, :boolean, default: false
      add :currency, :string, size: 3
      add :deleted_at, :utc_datetime
      add :notes, :text
      add :terms, :text
      add :meta_attributes, :jsonb
      add :items, :jsonb
      add :series_id, references(:series, type: :integer)
      add :customer_id, references(:customers, type: :integer), null: false

      timestamps()
    end

    create index(:invoices, [:customer_id])
    create index(:invoices, [:series_id])
  end
end

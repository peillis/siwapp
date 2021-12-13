defmodule Siwapp.Repo.Migrations.ReferencesToInvoices do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :series_id, references(:series, type: :integer)
      add :customer_id, references(:customers, type: :integer)
    end

    execute("CREATE UNIQUE INDEX common_unique_number_idx ON invoices(series_id, number)")
    execute("CREATE UNIQUE INDEX common_deleted_number_idx ON invoices(series_id, deleted_number)")
    execute("CREATE INDEX customer_id_idx ON invoices(customer_id)")
    execute("CREATE INDEX series_id_idx ON invoices(series_id)")

    alter table(:items) do
      add :invoices_id, references(:invoices, type: :integer)
    end

    execute("CREATE INDEX invoices_id_idx ON items(invoices_id)")

  end
end

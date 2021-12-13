defmodule Siwapp.Repo.Migrations.AddMapFieldToInvoices do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :meta_attributes, :jsonb
    end

    alter table(:customers) do
      add :meta_attributes, :jsonb
    end
  end
end

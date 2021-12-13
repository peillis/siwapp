defmodule Siwapp.Repo.Migrations.AddTextToInvoices do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :invoicing_address, :text
      add :shipping_address, :text
      add :notes, :text
      add :terms, :text
    end

    alter table(:customers) do
      add :invoicing_address, :text
      add :shipping_address, :text
    end
  end
end

defmodule Siwapp.Repo.Migrations.AddMetaAttributeColumnToCustomers do
  use Ecto.Migration

  def change do
    alter table( :customers ) do
      add :meta_attribute, :map, default: %{}
    end
  end
end

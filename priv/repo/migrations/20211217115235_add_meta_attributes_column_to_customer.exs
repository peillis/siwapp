defmodule Siwapp.Repo.Migrations.AddMetaAttributesColumnToCustomer do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add :meta_attribute, :jsonb
    end
  end
end

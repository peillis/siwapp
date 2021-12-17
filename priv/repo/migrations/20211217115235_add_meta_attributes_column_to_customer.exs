defmodule Siwapp.Repo.Migrations.AddMetaAttributesColumnToCustomer do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add :meta_attributes, :jsonb
    end
  end
end

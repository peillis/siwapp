defmodule Siwapp.Repo.Migrations.CreateCommons do
  use Ecto.Migration

  def change do
    create table(:series) do
      add :name, :string, size: 255
      add :code, :string, size: 255
      add :enabled, :boolean, default: true
      add :default, :boolean, default: false
      add :deleted_at, :utc_datetime
      add :first_number, :integer, default: 1
    end

    create table(:taxes) do
      add :name, :string, size: 50
      add :value, :integer
      add :enabled, :boolean, default: true
      add :default, :boolean, default: false
      add :deleted_at, :utc_datetime
    end

    create index(:taxes, [:name, :enabled], unique: true)
  end
end

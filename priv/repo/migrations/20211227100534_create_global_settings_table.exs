defmodule Siwapp.Repo.Migrations.CreateGlobalSettingsTable do
  use Ecto.Migration

  def change do
    create table(:global_settings) do
      add :key, :string
      add :value, :string

      timestamps()
    end
  end
end

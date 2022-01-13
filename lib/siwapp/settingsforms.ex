defmodule Siwapp.SettingsForm do
  alias Siwapp.Settings
  alias Siwapp.SettingsForms.SettingsForm

  @moduledoc false

  def change(%SettingsForm{} = form, attrs \\ %{}) do
    SettingsForm.changeset(form, attrs)
  end

  @doc """
  Function to prepare_data which will be changed to fill the form
  """
  def prepare_data, do: struct(SettingsForm, Enum.zip(SettingsForm.labels(), values()))

  @doc """
  Function which takes the filled form changeset and applies proper actions
  """
  @spec apply_user_settings(Ecto.Changeset.t()) ::
          {:ok, Ecto.Changeset.t()} | {:error, Ecto.Changeset.t()}
  def apply_user_settings(changeset) do
    if changeset.errors != [] do
      {:error, changeset}
    else
      changes = Map.to_list(changeset.changes)
      Enum.each(changes, fn {k, v} -> Settings.update({k, v}) end)
      {:ok, changeset}
    end
  end

  @doc """
  Function to get values saved in database
  """
  @spec values :: [nil | binary]
  def values do
    for key <- SettingsForm.labels(), do: Settings.get(key).value
  end
end

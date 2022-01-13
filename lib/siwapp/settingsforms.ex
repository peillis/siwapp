defmodule Siwapp.SettingsForm do
  alias Siwapp.Settings
  alias Siwapp.SettingsForms.SettingsForm

  @moduledoc false

  @spec get_pairs :: list
  def get_pairs, do: SettingsForm.pairs()

  def change, do: change(%SettingsForm{}, %{})

  def change(%SettingsForm{} = form, attrs \\ %{}) do
    SettingsForm.changeset(form, attrs)
  end

  @doc """
  Function to prepare_data which will be changed to fill the form
  """
  @spec prepare_data :: struct
  def prepare_data do
    case Settings.list() do
      [] -> %SettingsForm{}
      _ -> struct(SettingsForm, Enum.zip(SettingsForm.labels(), values()))
    end
  end

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
      Enum.each(changes, fn {k, v} -> Settings.act({k, v}) end)
      {:ok, changeset}
    end
  end

  @doc """
  Function to get values saved in database
  """
  @spec values :: [nil | binary]
  def values do
    for key <- SettingsForm.labels() do
      case Settings.get(key) do
        nil -> nil
        settingform -> settingform.value
      end
    end
  end
end

defmodule Siwapp.Settings do
  alias Siwapp.Repo
  alias Siwapp.Settings.{Setting, SettingBundle}

  @moduledoc """
  This module manage settings. For those with predefined keys in SettingBundle,
  which are also initialized using seeds, bundle operations can be used directly
  to change the full set of contemplated settings. Extra settings can be saved, as
  long as they have unique key, even though they won't be accessible to user using
  the form but only to developers using terminal.
  """

  @doc """
  Starts a setting given a key-value tuple (used only in seeds)
  """
  @spec create({atom | binary, binary}) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
  def create({key, value}) do
    %Setting{}
    |> change({to_string(key), value})
    |> Repo.insert()
  end

  @doc """
  Performs the SettingBundle changeset
  """
  def change_bundle(%SettingBundle{} = setting_bundle, attrs \\ %{}) do
    SettingBundle.changeset(setting_bundle, attrs)
  end

  @doc """
  Returns current SettingBundle (which is also useful to be changed and fill the SettingBundle form)
  """
  def current_bundle, do: struct(SettingBundle, Enum.zip(SettingBundle.labels(), values()))

  @doc """
  Takes a map of SettingBundle's parameters and saves each associated Setting if possible.
  Informs of the possibility to save those settings and returns the setting_bundle changeset
  """
  def apply_user_bundle(attrs) do
    changeset = change_bundle(current_bundle(), attrs)

    if changeset.valid? do
      changes = Map.to_list(changeset.changes)
      Enum.each(changes, fn {k, v} -> update({k, v}) end)
      {:ok, changeset}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  @doc """
  Returns the setting under the given key (atom or string)
  """
  @spec get(atom | binary) :: Setting.t() | nil
  def get(key),
    do: Repo.get_by(Setting, key: to_string(key))

  @doc """
  Returns the value of the setting associated to key (atom or string). Returns nil if
  this setting doesn't exist
  """
  def value(key) do
    case get(key) do
      nil -> nil
      setting -> setting.value
    end
  end

  @doc """
  Takes key-value tuple and updates the value of the Setting determined by key
  """
  @spec update({atom, any}) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
  def update({key, value}) do
    get(key)
    |> change({to_string(key), to_string(value)})
    |> Repo.update()
  end

  @spec change(Setting.t(), {binary, binary}) :: Ecto.Changeset.t()
  defp change(%Setting{} = setting, attrs) do
    Setting.changeset(setting, adequate_attrs(attrs))
  end

  @spec values :: [nil | binary]
  defp values do
    for key <- SettingBundle.labels(), do: value(key)
  end

  @spec adequate_attrs({binary, binary}) :: map
  defp adequate_attrs({key, value}), do: %{"key" => key, "value" => value}
end

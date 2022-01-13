defmodule Siwapp.Settings do
  alias Siwapp.Repo
  alias Siwapp.Settings.{Setting, SettingBundle}

  @moduledoc false

  def list, do: Repo.all(Setting)

  @doc """
  Function to make setting changeset with adequate_attrs
  """
  @spec change(Setting.t(), {binary, binary}) :: Ecto.Changeset.t()
  def change(%Setting{} = setting, attrs) do
    Setting.changeset(setting, adequate_attrs(attrs))
  end

  @doc """
  Creates a setting given a key
  """
  @spec create({atom, binary}) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
  def create({key, value}) do
    %Setting{}
    |> change({to_string(key), value})
    |> Repo.insert()
  end

  @doc """
  Updates associated setting to key with given value
  """
  @spec update({atom, any}) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
  def update({key, value}) do
    get(key)
    |> change({to_string(key), to_string(value)})
    |> Repo.update()
  end

  @doc """
  Gets setting for given key
  """
  @spec get(atom) :: Setting.t()
  def get(key),
    do: Enum.filter(list(), fn setting -> setting.key == to_string(key) end) |> List.first()

  def change_bundle(%SettingBundle{} = setting_bundle, attrs \\ %{}) do
    SettingBundle.changeset(setting_bundle, attrs)
  end

  @doc """
  Function to prepare_data which will be changed to fill the form
  """
  def prepare_data, do: struct(SettingBundle, Enum.zip(SettingBundle.labels(), values()))

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
      Enum.each(changes, fn {k, v} -> update({k, v}) end)
      {:ok, changeset}
    end
  end

  @doc """
  Function to get values saved in database
  """
  @spec values :: [nil | binary]
  def values do
    for key <- SettingBundle.labels(), do: get(key).value
  end

  @spec adequate_attrs({binary, binary}) :: map
  defp adequate_attrs({key, value}), do: %{"key" => key, "value" => value}
end

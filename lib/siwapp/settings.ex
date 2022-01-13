defmodule Siwapp.Settings do
  alias Siwapp.Repo
  alias Siwapp.Settings.{Setting, SettingBundle}

  @moduledoc false

  @doc """
  Creates a setting given a key
  """
  @spec create({atom, binary}) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
  def create({key, value}) do
    %Setting{}
    |> change({to_string(key), value})
    |> Repo.insert()
  end

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

  @spec list :: Setting.t()
  defp list, do: Repo.all(Setting)

  @spec change(Setting.t(), {binary, binary}) :: Ecto.Changeset.t()
  defp change(%Setting{} = setting, attrs) do
    Setting.changeset(setting, adequate_attrs(attrs))
  end

  @spec update({atom, any}) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
  defp update({key, value}) do
    get(key)
    |> change({to_string(key), to_string(value)})
    |> Repo.update()
  end

  @spec get(atom) :: Setting.t()
  defp get(key),
    do: Enum.filter(list(), fn setting -> setting.key == to_string(key) end) |> List.first()

  @spec values :: [nil | binary]
  defp values do
    for key <- SettingBundle.labels(), do: get(key).value
  end

  @spec adequate_attrs({binary, binary}) :: map
  defp adequate_attrs({key, value}), do: %{"key" => key, "value" => value}
end

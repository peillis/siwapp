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

  def prepare_data(:cache) do
    case Cachex.get(:my_cache, :settings_data) do
      {:ok, nil} ->
        settings_data = prepare_data()
        Cachex.put(:my_cache, :settings_data, settings_data, ttl: :timer.seconds(300))
        settings_data

      {:ok, settings_data} ->
        settings_data
    end
  end

  @doc """
  Function which takes the filled form and applies proper actions
  """
  def apply_user_settings(attrs) do
    changeset = change_bundle(prepare_data(), attrs)

    if changeset.valid? do
      changes = Map.to_list(changeset.changes)
      Enum.each(changes, fn {k, v} -> update({k, v}) end)
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

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
    do: Repo.get_by(Setting, key: to_string(key))

  @spec values :: [nil | binary]
  defp values do
    for key <- SettingBundle.labels(), do: get(key).value
  end

  @spec adequate_attrs({binary, binary}) :: map
  defp adequate_attrs({key, value}), do: %{"key" => key, "value" => value}
end

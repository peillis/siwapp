defmodule Siwapp.Settings do
  alias Siwapp.Repo
  alias Siwapp.Settings.Setting

  @moduledoc false

  def list, do: Repo.all(Setting)

  @doc """
  Function to make setting changeset with adequate_attrs
  """
  @spec change(Setting.t(), atom | tuple) :: Ecto.Changeset.t()
  def change(%Setting{} = setting, attrs) do
    Setting.changeset(setting, adequate_attrs(attrs))
  end

  @doc """
  Creates a setting given a key
  """
  @spec create(atom) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
  def create(key) when is_atom(key) do
    %Setting{}
    |> change(key)
    |> Repo.insert()
  end

  @doc """
  Updates associated setting to key with given value
  """
  @spec update(tuple) :: {:ok, Setting.t()} | {:error, Ecto.Changeset.t()}
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

  @doc """
  Returns correct attrs to apply changeset to {key, value}
  """
  @spec adequate_attrs(tuple | atom) :: map
  def adequate_attrs(key) when is_atom(key), do: %{"key" => to_string(key)}
  def adequate_attrs({key, value}), do: %{"key" => to_string(key), "value" => value}
end

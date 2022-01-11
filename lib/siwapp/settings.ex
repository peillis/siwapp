defmodule Siwapp.Settings do
  alias Siwapp.Repo
  alias Siwapp.Settings.Setting

  @moduledoc false
  def new, do: %Setting{}
  def new(key, value \\ nil), do: %Setting{key: to_string(key), value: value}

  def list, do: Repo.all(Setting) |> Enum.sort_by(fn setting -> setting.id end)

  def create(attrs \\ %{}) do
    %Setting{}
    |> Setting.changeset(adequate_attrs(attrs))
    |> Repo.insert()
  end

  def update(%Setting{} = setting, attrs) do
    setting
    |> Setting.changeset(adequate_attrs(attrs))
    |> Repo.update()
  end

  @doc """
  Function which decides what should be done with certain tuple of key and value received from form
  """
  @spec act(tuple) :: {:ok, Ecto.Changeset.t()} | {:error, Ecto.Changeset.t()}
  def act({key, value}) do
    case get(key) do
      nil ->
        create({to_string(key), to_string(value)})

      _ ->
        case value do
          nil -> delete(get(key))
          value -> update(get(key), to_string(value))
        end
    end
  end

  def delete(%Setting{} = setting) do
    Repo.delete(setting)
  end

  def change(%Setting{} = setting, attrs \\ %{}) do
    Setting.changeset(setting, adequate_attrs(attrs))
  end

  @spec get(atom) :: nil | struct
  def get(key), do: if(first_value?(key), do: nil, else: get!(key))

  defp get!(key),
    do: Enum.filter(list(), fn setting -> setting.key == to_string(key) end) |> List.first()

  @doc """
  Returns correct attrs to apply changeset to {key, value}
  """
  @spec adequate_attrs(map | binary | tuple) :: map
  def adequate_attrs(%{}), do: %{}
  def adequate_attrs(value) when is_binary(value), do: %{"value" => value}
  def adequate_attrs({key, value}), do: %{"key" => to_string(key), "value" => value}

  @doc """
  Returns if a key isn't in database yet
  """
  @spec first_value?(atom) :: boolean
  def first_value?(key),
    do: Enum.empty?(Enum.filter(list(), fn setting -> setting.key == to_string(key) end))
end

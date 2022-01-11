defmodule Siwapp.Settings do
  alias Siwapp.Repo
  alias Siwapp.Settings.Setting

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

  def act({key, value}) do
    IO.inspect({key, value})

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

  def get(key), do: if(first_value?(key), do: nil, else: get!(key))

  defp get!(key),
    do: Enum.filter(list(), fn setting -> setting.key == to_string(key) end) |> List.first()

  defp adequate_attrs(%{}), do: %{}
  defp adequate_attrs(value) when is_binary(value), do: %{"value" => value}
  defp adequate_attrs({key, value}), do: %{"key" => to_string(key), "value" => value}

  def first_value?(key),
    do: length(Enum.filter(list(), fn setting -> setting.key == to_string(key) end)) == 0
end

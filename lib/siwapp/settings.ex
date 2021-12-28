defmodule Siwapp.Settings do
  alias Siwapp.Repo
  alias Siwapp.Settings.Setting

  @current_labels [
    "Company",
    "Company VAT ID",
    "Company address",
    "Company phone",
    "Company email",
    "Company website",
    "Company logo",
    "Currency",
    "Legal terms",
    "Days to due"
  ]

  def list(), do: Repo.all(Setting) |> Enum.sort_by(fn setting -> setting.id end)

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

  def delete(%Setting{} = setting) do
    Repo.delete(setting)
  end

  def change(%Setting{} = setting, attrs \\ %{}) do
    Setting.changeset(setting, adequate_attrs(attrs))
  end

  def prepare_current_settings() do
    for key <- @current_labels do
      if first_value?(key) do
        %Setting{key: key}
      else
        value = get(key).value
        %Setting{key: key, value: value}
      end
    end
  end

  defp first_value?(key),
    do: length(Enum.filter(list(), fn setting -> setting.key == key end)) == 0

  def get(key), do: if(first_value?(key), do: nil, else: get!(key))

  defp get!(key),
    do: Enum.filter(list(), fn setting -> setting.key == key end) |> List.first()

  defp adequate_attrs(%{}), do: %{}
  defp adequate_attrs(value) when is_binary(value), do: %{"value" => value}
  defp adequate_attrs({key, value}), do: %{"key" => key, "value" => value}
end

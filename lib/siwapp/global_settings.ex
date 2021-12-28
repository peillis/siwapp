defmodule Siwapp.GlobalSettings do
  alias Siwapp.Repo
  alias Siwapp.Schema.GlobalSetting

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

  def list(), do: Repo.all(GlobalSetting) |> Enum.sort_by(fn schema -> schema.id end)

  def create(attrs \\ %{}) do
    %GlobalSetting{}
    |> GlobalSetting.changeset(adequate_attrs(attrs))
    |> Repo.insert()
  end

  @doc """
  Updates a global_setting 
  """
  def update(%GlobalSetting{} = global_settings, attrs) do
    global_settings
    |> GlobalSetting.changeset(adequate_attrs(attrs))
    |> Repo.update()
  end

  @doc """
  Deletes a global_setting 
  """
  def delete(%GlobalSetting{} = global_settings) do
    Repo.delete(global_settings)
  end

  @doc """
  Gets a global_setting by id
  """
  def get!(id), do: Repo.get!(GlobalSetting, id)

  def change(%GlobalSetting{} = global_setting, attrs \\ %{}) do
    GlobalSetting.changeset(global_setting, adequate_attrs(attrs))
  end

  def prepare_current_global_settings() do
    for key <- @current_labels do
      if first_value?(key) do
        %GlobalSetting{key: key}
      else
        value = schema_for_key(key).value
        %GlobalSetting{key: key, value: value}
      end
    end
  end

  defp first_value?(key), do: length(Enum.filter(list(), fn schema -> schema.key == key end)) == 0

  def schema_for_key(key), do: if(first_value?(key), do: nil, else: schema_for_key!(key))

  defp schema_for_key!(key),
    do: Enum.filter(list(), fn schema -> schema.key == key end) |> List.first()

  defp adequate_attrs(%{}), do: %{}
  defp adequate_attrs(value) when is_binary(value), do: %{"value" => value}
  defp adequate_attrs({key, value}), do: %{"key" => key, "value" => value}
end

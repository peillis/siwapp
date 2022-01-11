defmodule Siwapp.SettingsForm do
  alias Siwapp.Settings
  alias Siwapp.Settings.Form

  @spec get_pairs :: list
  def get_pairs, do: Form.pairs()

  def change, do: change(%Form{}, %{})

  def change(%Form{} = form, attrs \\ %{}) do
    Form.changeset(form, attrs)
  end

  @doc """
  Function to prepare_data which will be changed to fill the form
  """
  @spec prepare_data :: struct
  def prepare_data do
    case Settings.list() do
      [] -> %Form{}
      _ -> struct(Form, Enum.zip(Form.labels(), values))
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
      changeset = change(prepare_data)
      {:ok, changeset}
    end
  end

  @doc """
  Function to get the associated Setting structs for the saved data. Used only in the old_settings version
  """
  @spec prepare_current_settings :: [struct]
  def prepare_current_settings() do
    for key <- Form.labels() do
      if Settings.first_value?(key) do
        Settings.new(key)
      else
        value = Settings.get(key).value
        Settings.new(key, value)
      end
    end
  end

  @doc """
  Function to get values saved in database
  """
  @spec values :: [nil | binary]
  def values do
    for key <- Form.labels() do
      case Settings.get(key) do
        nil -> nil
        form -> form.value
      end
    end
  end
end

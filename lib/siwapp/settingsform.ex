defmodule Siwapp.SettingsForm do
  
  alias Siwapp.Settings
  alias Siwapp.Settings.Form

  def get_pairs, do: Form.pairs

  def change, do: change(%Form{}, %{})
  def change(%Form{} = form, attrs \\ %{}) do
    Form.changeset(form, attrs)
  end

  def prepare_data do
    case Settings.list do
      [] -> %Form{}
      _  -> struct(Form, Enum.zip(Form.labels, values)) 
    end
  end

  def apply_user_settings(changeset) do
    if changeset.errors != [] do 
      {:error, changeset}
    else
      changes = Map.to_list(changeset.changes)
      data = changeset.data
      Enum.each(changes, fn {k,v} -> Settings.act({k,v}) end)
      {:ok, changeset}
    end
 end
 
  def prepare_current_settings() do
    for key <- Form.labels do
      if Settings.first_value?(key) do
        Settings.new(key)
      else
        value = Settings.get(key).value
        Settings.new(key, value)
      end
    end
  end

  def values, do: for key <- Enum.reject(Form.labels, &(Settings.first_value?(&1) ) ), do: Settings.get(key).value

end


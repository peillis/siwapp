defmodule Siwapp.SettingsForm do
  
  alias Siwapp.Settings.Form

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


  def change, do: change(%Form{}, %{})

  def change(%Form{} = form, attrs \\ %{}) do
    Form.changeset(form, attrs)
  end

  def apply_user_settings(changeset, attrs) do
    """
    Still to be done
    """
  end

"""
  def changeset(%{}, attrs \\ %{}) do
    types = get_types
    {prepare_data, types}
    |> cast(attrs, Map.keys(types))
  end
  def changeset(settingsform, attrs) do
    types = get_types
    {settingsform, types}
    |> cast(attrs, Map.keys(types))
  end

  defp prepare_data, do: Map.new(get_labels, fn label -> {label, nil} end)
  defp get_labels, do: for label <- @current_labels, do: String.to_atom(label)
"""  
end


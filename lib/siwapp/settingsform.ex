defmodule Siwapp.SettingsForm do
  import Ecto.Changeset 

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

  @current_types [
    :string,
    :string,
    :string,
    :integer,
    :string,
    :string,
    :string,
    :string,
    :integer
  ]

  defp labels_in_atoms(labels), do: for label <- labels, do: String.to_atom(label)

  defp get_types, do: Map.new( Enum.zip( labels_in_atoms(@current_labels), @current_types ) )

  def changeset(settingsform, attrs \\ %{}) do
    types = get_types
    {settingsform, types}
    |> cast(attrs, Map.keys(types))
  end
end


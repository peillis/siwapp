defmodule Siwapp.SettingsForms.SettingsForm do
  import Ecto.Changeset

  @moduledoc false

  @fields_keywordlist [
    company: :string,
    company_vat_id: :string,
    company_phone: :integer,
    company_email: :string,
    company_website: :string,
    company_logo: :string,
    currency: :string,
    days_to_due: :integer,
    company_address: :string,
    legal_terms: :string
  ]
  @labels Keyword.keys(@fields_keywordlist)

  defstruct @labels

  def changeset(settingsform, attrs \\ %{}) do
    {settingsform, fields_map()}
    |> cast(attrs, labels())
    |> validate_format(:company_email, ~r/@/)
    # Example list of currency, will be updated to whole
    |> validate_inclusion(:currency, ["USD", "EUR"])
  end

  def labels, do: @labels
  def pairs, do: Enum.zip(labels(), types())
  def fields_map, do: Map.new(@fields_keywordlist)
  defp types, do: for(key <- labels(), do: Map.get(fields_map(), key))
end

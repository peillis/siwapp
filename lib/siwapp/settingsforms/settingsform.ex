defmodule Siwapp.SettingsForms.SettingsForm do
  import Ecto.Changeset

  @moduledoc false

  @fields_keywordlist [
    company: :string,
    company_vat_id: :string,
    company_phone: :string,
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
    |> validate_email()
    # Example list of currency, will be updated to whole
    |> validate_inclusion(:currency, ["USD", "EUR"])
  end

  @spec labels :: [atom]
  def labels, do: @labels
  @spec fields_map :: map
  def fields_map, do: Map.new(@fields_keywordlist)

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end
end

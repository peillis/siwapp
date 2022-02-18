defmodule Siwapp.Settings.SettingBundle do
  import Ecto.Changeset

  @moduledoc """
  SettingBundle is the data structure to manage SettingsController form operations. It's a struct, whose keys consist of
  all current settings available to change via form or terminal, updating settings values' of those already stored in db
  (which are initialized in the seeds)
  """

  @fields_keywordlist [
    company: :string,
    company_vat_id: :string,
    company_phone: :string,
    company_email: :string,
    company_website: :string,
    currency: :string,
    days_to_due: :integer,
    company_address: :string,
    legal_terms: :string
  ]

  @labels Keyword.keys(@fields_keywordlist)

  @email_regex Application.compile_env!(:siwapp, :email_regex)

  defstruct @labels

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(setting_bundle, attrs \\ %{}) do
    {setting_bundle, fields_map()}
    |> cast(attrs, @labels)
    |> validate_email()
    # Example list of currency, will be updated to whole
    |> validate_length(:currency, max: 3)
  end

  @spec fields_map :: map
  defp fields_map, do: Map.new(@fields_keywordlist)

  @spec validate_email(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_email(changeset) do
    changeset
    |> validate_format(:company_email, @email_regex, message: "must have the @ sign and no spaces")
    |> validate_length(:company_email, max: 160)
  end
end

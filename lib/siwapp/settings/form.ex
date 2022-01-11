defmodule Siwapp.Settings.Form do
  import Ecto.Changeset

  @labels [
    :company,
    :company_vat_id,
    :company_address,
    :company_phone,
    :company_email,
    :company_website,
    :company_logo,
    :currency,
    :legal_terms,
    :days_to_due
  ]

  @types [
    :string,
    :string,
    :string,
    :integer,
    :string,
    :string,
    :string,
    :string,
    :string,
    :integer
  ]

  defstruct @labels

  def changeset(form, attrs \\ %{}) do
    {form, fields_map}
    |> cast(attrs, Map.keys(fields_map))
    |> validate_format(:company_email, ~r/@/)
    # Lista de ejemplo, ya se incluirán todas como constantes
    |> validate_inclusion(:currency, ["USD", "EUR"])
  end

  def labels, do: @labels
  def pairs, do: Enum.zip(@labels, @types)
  defp fields_map, do: Map.new(pairs)
end

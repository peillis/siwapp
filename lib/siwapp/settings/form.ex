defmodule Siwapp.Settings.Form do
  import Ecto.Changeset

  @moduledoc false

  @fields_map %{
    company: :string,
    company_vat_id: :string,
    company_address: :string,
    company_phone: :integer,
    company_email: :string,
    company_website: :string,
    company_logo: :string,
    currency: :string,
    legal_terms: :string,
    days_to_due: :integer
  }
  @labels Map.keys(@fields_map)

  defstruct @labels

  def changeset(form, attrs \\ %{}) do
    {form, @fields_map}
    |> cast(attrs, labels())
    |> validate_format(:company_email, ~r/@/)
    # Example list of currency, will be updated to whole
    |> validate_inclusion(:currency, ["USD", "EUR"])
  end

  def labels, do: @labels
  def pairs, do: Enum.zip(labels(), types())
  defp types, do: for(key <- labels(), do: Map.get(@fields_map, key))
end

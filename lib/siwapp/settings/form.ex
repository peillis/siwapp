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


  defstruct @labels

  def changeset(form, attrs \\ %{}) do
    types = get_types
    {form, types}
    |> cast(attrs, Map.keys(types))
  end
  
  
  defp get_types, do: Map.new( Enum.zip( @labels, @current_types ) )

end

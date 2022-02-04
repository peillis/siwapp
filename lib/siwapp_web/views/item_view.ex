defmodule SiwappWeb.ItemView do
  use SiwappWeb, :view

  alias Phoenix.HTML.FormData
  alias SiwappWeb.PageView

  @spec get_existing_taxes(FormData.t()) :: [] | [tuple]
  def get_existing_taxes(fi) do
    Ecto.Changeset.get_field(fi.source, :taxes)
    |> Enum.map(&{&1.name, &1.id})
  end

  @spec item_net_amount(FormData.t()) :: binary
  def item_net_amount(fi) do
    (Ecto.Changeset.get_field(fi.source, :net_amount) / 100)
    |> :erlang.float_to_binary(decimals: 2)
  end

  defp net_amount(changeset) do
    Ecto.Changeset.get_field(changeset, :net_amount)
    |> PageView.set_currency(Ecto.Changeset.get_field(changeset, :currency))
  end

  defp taxes_amounts(changeset) do
    Ecto.Changeset.get_field(changeset, :taxes_amounts)
    |> Enum.map(fn {k, v} ->
      {k, PageView.set_currency(v, Ecto.Changeset.get_field(changeset, :currency))}
    end)
  end

  defp gross_amount(changeset) do
    Ecto.Changeset.get_field(changeset, :gross_amount)
    |> PageView.set_currency(Ecto.Changeset.get_field(changeset, :currency))
  end
end

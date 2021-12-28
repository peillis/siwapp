defmodule Siwapp.Invoices.Query do
  alias Siwapp.Invoices.Invoice

  import Ecto.Query

  def list_preload() do
    from i in Invoice,
      join: c in assoc(i, :customer),
      preload: [customer: c]
  end

  def by(field, value) do
    where(Invoice, ^[{field, value}])
  end

  def with_terms(terms) do
    from(i in Invoice,
      join: it in Siwapp.Invoices.Item,
      where: it.description == ^terms,
      or_where: i.email == ^terms,
      or_where: i.name == ^terms,
      or_where: i.identification == ^terms
    )
  end

  def issue_date_gteq(date) do
    from(i in Invoice,
      where: i.issue_date >= ^date
    )
  end

  def issue_date_lteq(date) do
    from(i in Invoice,
      where: i.issue_date <= ^date
    )
  end
end
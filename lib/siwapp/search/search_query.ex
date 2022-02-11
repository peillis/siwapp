defmodule Siwapp.Search.SearchQuery do
  @moduledoc """
  Search Queries
  """
  import Ecto.Query

  @doc """
  Get invoices, customers or recurring_invoices by comparing value with name, email or id fields
  """
  def name_email_or_id(query, value) do
    query
    |> where([q], ilike(q.name, ^"%#{value}%"))
    |> or_where([q], ilike(q.email, ^"%#{value}%"))
    |> or_where([q], ilike(q.identification, ^"%#{value}%"))
  end
end

defmodule Siwapp.Search.SearchQuery do
  @moduledoc """
  Search Queries
  """
  import Ecto.Query
  alias Siwapp.{Query, Repo}
  alias Siwapp.Invoices.InvoiceQuery
  alias Siwapp.RecurringInvoices.RecurringInvoiceQuery

  def prueba(query, key, value) do
    case key do
      "search_input" ->
        name_email_or_id(query, value)

      "name" ->
        key = convert_to_atom(key)

        Query.search_in_string(query, key, value)

      "number" ->
        where(query, [q], q.number == type(^value, :integer))

      "series" ->
        query
        |> join(:inner, [q], s in Siwapp.Commons.Series, on: q.series_id == s.id)
        |> where([q, s], ilike(s.name, ^"%#{value}%"))

      date
      when date in [
             "issue_from_date",
             "issue_to_date",
             "starting_from_date",
             "starting_to_date",
             "finishing_from_date",
             "finishing_to_date"
           ] ->
        value = Date.from_iso8601!(value)
        from_or_to(query, key, value)

      "status" ->
        type_of_status(query, value)

      "key" ->
        where(query, [q], not is_nil(q.meta_attributes[^value]))

      "value" ->
        keys = get_all_keys(query)

        Enum.reduce(keys, query, fn this_key, acc_query ->
          or_where(acc_query, [q], q.meta_attributes[^this_key] == ^value)
        end)
    end
  end

  @doc """
  Get invoices, customers or recurring_invoices by comparing value with name, email or id fields
  """
  defp name_email_or_id(query, value) do
    query
    |> where([q], ilike(q.name, ^"%#{value}%"))
    |> or_where([q], ilike(q.email, ^"%#{value}%"))
    |> or_where([q], ilike(q.identification, ^"%#{value}%"))
  end

  defp from_or_to(query, key, value) do
    if String.contains?(key, "_from_") do
      type_of_from_date(query, key, value)
    else
      type_of_to_date(query, key, value)
    end
  end

  defp type_of_from_date(query, key, value) do
    cond do
      String.starts_with?(key, "issue") ->
        InvoiceQuery.issue_date_gteq(query, value)

      String.starts_with?(key, "starting") ->
        RecurringInvoiceQuery.starting_date_gteq(query, value)

      true ->
        RecurringInvoiceQuery.finishing_date_gteq(query, value)
    end
  end

  defp type_of_to_date(query, key, value) do
    cond do
      String.starts_with?(key, "issue") ->
        InvoiceQuery.issue_date_lteq(query, value)

      String.starts_with?(key, "starting") ->
        RecurringInvoiceQuery.starting_date_lteq(query, value)

      true ->
        RecurringInvoiceQuery.finishing_date_lteq(query, value)
    end
  end

  defp type_of_status(query, value) do
    case value do
      v when v in ["Draft", "Paid", "Failed"] ->
        value = convert_to_atom(value)

        query
        |> where([q], field(q, ^value) == true)

      "Pending" ->
        query
        |> where(draft: false)
        |> where(paid: false)
        |> where(failed: false)
        |> where([q], is_nil(q.due_date) or q.due_date > ^Date.utc_today())

      "Past Due" ->
        query
        |> where(draft: false)
        |> where(paid: false)
        |> where(failed: false)
        |> where([q], not is_nil(q.due_date))
        |> where([q], q.due_date < ^Date.utc_today())
    end
  end

  defp convert_to_atom(value) do
    value
    |> String.downcase()
    |> String.to_atom()
  end

  defp get_all_keys(query) do
    query
    |> select([q], q.meta_attributes)
    |> Repo.all()
    |> Enum.map(&Map.keys(&1))
    |> List.flatten()
    |> Enum.uniq()
  end
end

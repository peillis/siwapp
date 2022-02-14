defmodule Siwapp.Search.SearchQuery do
  @moduledoc """
  Search Queries
  """
  import Ecto.Query
  alias Siwapp.Invoices.InvoiceQuery
  alias Siwapp.{Query, Repo}
  alias Siwapp.RecurringInvoices.RecurringInvoiceQuery

  @doc """
  For each key, one different query
  """
  def filter_by(query, key, value) do
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
        type_of_date(query, key, value)

      "status" ->
        type_of_status(query, value)

      "key" ->
        where(query, [q], not is_nil(q.meta_attributes[^value]))

      "value" ->
        keys = get_keys_associated_to_value(query, value)

        value_for_each_key(keys, query, value)
    end
  end

  # Get invoices, customers or recurring_invoices by comparing value with name, email or id fields
  defp name_email_or_id(query, value) do
    query
    |> where(
      [q],
      ilike(q.name, ^"%#{value}%") or ilike(q.email, ^"%#{value}%") or
        ilike(q.identification, ^"%#{value}%")
    )
  end

  # There are 6 types of dates; 3 "to_dates" and 3 "from_dates". Depending on the key name,
  # the function will make different queries
  defp type_of_date(query, key, value) do
    cond do
      String.starts_with?(key, "issue_from") ->
        InvoiceQuery.issue_date_gteq(query, value)

      String.starts_with?(key, "issue_to") ->
        InvoiceQuery.issue_date_lteq(query, value)

      String.starts_with?(key, "starting_from") ->
        RecurringInvoiceQuery.starting_date_gteq(query, value)

      String.starts_with?(key, "starting_to") ->
        RecurringInvoiceQuery.starting_date_lteq(query, value)

      String.starts_with?(key, "finishing_from") ->
        RecurringInvoiceQuery.finishing_date_gteq(query, value)

      true ->
        RecurringInvoiceQuery.finishing_date_lteq(query, value)
    end
  end

  # It implements the same algorithm of the Invoices Context Status function.
  # If a user filters by draft, paid or failed,
  # the query will search if the field with same name as value is true.
  # If user filters by pending, the query will search if draft, paid and failed are false and also if due_date is nil
  # or if due_date is greater than today
  # Finally if user filters by past due, the query will do the same as pending, but in this case due_date must exists
  # and has to be less than today
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

  # Get keys of a jsonb(meta_attributes) which are associated with the value a user inputs
  defp get_keys_associated_to_value(query, value) do
    query
    |> select([q], q.meta_attributes)
    |> Repo.all()
    |> Enum.reject(&(&1 == %{}))
    |> Enum.uniq()
    |> Enum.map(&compare_with_value(&1, value))
    |> Enum.reject(&is_nil(&1))
  end

  defp value_for_each_key(keys, query, value) do
    if keys == [] do
      where(query, [q], nil)
    else
      [first_key | rest_of_keys] = keys
      first_query = where(query, [q], q.meta_attributes[^first_key] == ^value)

      Enum.reduce(rest_of_keys, first_query, fn key_associated, acc_query ->
        where(query, [a], a.meta_attributes[^key_associated] == ^value)
        |> union_all(^acc_query)
      end)
    end
  end

  # It will compares if the value inside the map is the same as the value a user is filtering by.
  # If true get the key of the map
  defp compare_with_value(map, value) do
    if Map.values(map) == [value] do
      [key] = Map.keys(map)
      key
    else
      nil
    end
  end
end

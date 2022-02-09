defmodule Siwapp.Search do
  @moduledoc """
  Context for
  """
  alias Siwapp.Repo
  alias Siwapp.Search.SearchQuery

  def filters(query, value) do
    query
    |> SearchQuery.name_email_or_id(value)
    |> Repo.all()
  end
end

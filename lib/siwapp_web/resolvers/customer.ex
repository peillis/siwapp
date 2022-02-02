defmodule SiwappWeb.Resolvers.Customer do
  @moduledoc false

  alias Siwapp.Customers
  alias SiwappWeb.Resolvers.Errors

  def list(%{limit: limit, offset: offset}, _resolution) do
    {:ok, Customers.list(limit, offset)}
  end

  def create(args, _resolution) do
    case Customers.create(args) do
      {:ok, customer} ->
        {:ok, customer}

      {:error, changeset} ->
        {:error, message: "Failed!", details: Errors.extract(changeset)}
    end
  end
end

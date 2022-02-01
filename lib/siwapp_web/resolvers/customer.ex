defmodule SiwappWeb.Resolvers.Customer do
  @moduledoc false

  alias Siwapp.Customers
  alias SiwappWeb.Resolvers.Errors

  def list(_args, _resolution) do
    {:ok, Customers.list()}
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

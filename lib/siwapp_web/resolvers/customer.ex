defmodule SiwappWeb.Resolvers.Customer do
  @moduledoc false

  alias Siwapp.Customers
  alias SiwappWeb.Resolvers.Errors

  @spec list(map(), Absinthe.Resolution.t()) :: {:ok, [Customers.Customer.t()]}
  def list(%{limit: limit, offset: offset}, _resolution) do
    {:ok, Customers.list(limit, offset)}
  end

  @spec create(map(), Absinthe.Resolution.t()) :: {:error, map()} | {:ok, Customers.Customer.t()}
  def create(args, _resolution) do
    case Customers.create(args) do
      {:ok, customer} ->
        {:ok, customer}

      {:error, changeset} ->
        {:error, message: "Failed!", details: Errors.extract(changeset)}
    end
  end
end

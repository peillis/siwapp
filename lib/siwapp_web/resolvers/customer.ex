defmodule SiwappWeb.Resolvers.Customer do
  @moduledoc false

  alias Siwapp.Customers

  def list(_parent, _args, _resolution) do
    {:ok, Customers.list()}
  end

  def create(_parent, args, _resolution) do
    Customers.create(args)
  end
end

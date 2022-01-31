defmodule SiwappWeb.Resolvers.Content do
  def list_customers(_parent, _args, _resolution) do
    {:ok, Siwapp.Customers.list()}
  end
end

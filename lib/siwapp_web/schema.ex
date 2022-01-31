defmodule SiwappWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  import_types(SiwappWeb.Schema.ContentTypes)

  alias SiwappWeb.Resolvers

  query do
    @desc "Get all customers"
    field :customers, list_of(:customer) do
      resolve(&Resolvers.Content.list_customers/3)
    end
  end
end

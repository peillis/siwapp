defmodule SiwappWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  import_types(SiwappWeb.Schema.Types)

  alias SiwappWeb.Resolvers

  query do
    @desc "Get all customers"
    field :customers, list_of(:customer) do
      resolve(&Resolvers.Customer.list/2)
    end
  end

  mutation do
    @desc "Create a customer"
    field :create_customer, type: :customer do
      arg(:name, non_null(:string))
      arg(:identification, :string)
      arg(:email, :string)
      arg(:contact_person, :string)
      arg(:invoicing_address, :string)
      arg(:shipping_address, :string)

      resolve(&Resolvers.Customer.create/2)
    end
  end
end

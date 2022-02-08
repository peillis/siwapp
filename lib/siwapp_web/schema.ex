defmodule SiwappWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  import_types(SiwappWeb.Schema.CustomerTypes)
  import_types(SiwappWeb.Schema.InvoiceTypes)
  import_types(SiwappWeb.Schema.ItemTypes)
  import_types(Absinthe.Type.Custom)

  alias SiwappWeb.Resolvers

  query do
    @desc "Get all customers"
    field :customers, list_of(:customer) do
      arg(:limit, :integer, default_value: 10)
      arg(:offset, :integer, default_value: 0)

      resolve(&Resolvers.Customer.list/2)
    end

    @desc "Get all invoices"
    field :invoices, list_of(:invoice) do
      resolve(&Resolvers.Invoice.list/2)
    end

    @desc "Get all invoices of a customer"
    field :invoices_of_a_customer, list_of(:invoice) do
      arg(:customer_id, non_null(:id))
      resolve(&Resolvers.Invoice.list/2)
    end
  end

  input_object :items do
    field :id, :id
    field :quantity, :integer
    field :discount, :integer
    field :description, :string
    field :virtual_unitary_cost, :string
    field :taxes, list_of(:string)
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

    @desc "Create an invoice"
    field :create_invoice, type: :invoice do
      arg(:name, non_null(:string))
      arg(:identification, :string)
      arg(:email, :string)
      arg(:contact_person, :string)
      arg(:invoicing_address, :string)
      arg(:shipping_address, :string)
      arg(:terms, :string)
      arg(:notes, :string)
      arg(:series_id, non_null(:id))
      arg(:number, :string)
      arg(:currency, :string)
      arg(:issue_date, non_null(:date))
      arg(:due_date, :date)
      arg(:draft, :boolean)
      arg(:items, list_of(:items))
      arg(:gross_amount, :string)
      arg(:net_amount, :string)
      arg(:paid_amount, :string)
      arg(:paid, :boolean)
      arg(:failed, :boolean)
      arg(:sent_by_email, :boolean)

      resolve(&Resolvers.Invoice.create/2)
    end
  end
end

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
      arg(:customer_id, :id)
      arg(:limit, :integer, default_value: 10)
      arg(:offset, :integer, default_value: 0)

      resolve(&Resolvers.Invoice.list/2)
    end
  end

  input_object :items do
    field :id, :id
    field :quantity, :integer
    field :discount, :integer
    field :description, :string
    field :unitary_cost, :integer
    field :taxes, list_of(:string)
  end

  input_object :update_invoice_params do
    field :name, :string
    field :identification, :string
    field :contact_person, :string
    field :email, :string
    field :invoicing_address, :string
    field :shipping_address, :string
    field :terms, :string
    field :notes, :string
    field :series_id, :id
    field :currency, :string
    field :issue_date, :date
    field :due_date, :date
    field :draft, :boolean
    field :items, list_of(:items)
    field :failed, :boolean
    field :recurring_invoice, :id
    field :sent_by_email, :boolean
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
      arg(:currency, :string)
      arg(:issue_date, non_null(:date))
      arg(:due_date, :date)
      arg(:draft, :boolean)
      arg(:items, list_of(:items))
      arg(:failed, :boolean)

      resolve(&Resolvers.Invoice.create/2)
    end

    field :update_invoice, type: :invoice do
      arg(:id, non_null(:integer))
      arg(:invoice, :update_invoice_params)

      resolve(&Resolvers.Invoice.update/2)
    end

    field :delete_invoice, type: :invoice do
      arg(:id, non_null(:integer))

      resolve(&Resolvers.Invoice.delete/2)
    end
  end
end

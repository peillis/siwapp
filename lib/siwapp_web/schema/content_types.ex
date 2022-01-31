defmodule SiwappWeb.Schema.ContentTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :customer do
    field :id, :id
    field :identification, :string
    field :name, :string
    field :email, :string
    field :contact_person, :string
    field :invoicing_address, :string
    field :shipping_address, :string
  end
end

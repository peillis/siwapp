defmodule SiwappWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :customer do
    field :id, :id
    field :identification, :string
    field :name, :string
  end
end

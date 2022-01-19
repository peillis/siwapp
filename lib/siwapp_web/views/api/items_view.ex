defmodule SiwappWeb.Api.ItemsView do
  use JSONAPI.View, type: "items"

  def fields, do: [:quantity, :discount, :description, :unitary_cost]
end

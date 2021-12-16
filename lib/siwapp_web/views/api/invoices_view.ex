defmodule SiwappWeb.Api.InvoicesView do
  use JSONAPI.View, type: "invoices"


  def fields, do: [:customer_id, :name, :inserted_at]

  def render("index.json", %{list: json}) do
      json
  end

  def render("show.json", %{show: json}) do
    json
end

end

defmodule SiwappWeb.Api.CustomersView do
  use JSONAPI.View, type: "customer"

  def fields,
    do: [
      :active,
      :contact_person,
      :email,
      :id,
      :identification,
      :invoicing_address,
      :meta_attributes,
      :name,
      :shipping_address
    ]

  def relationships do
    []
  end

  def render("show.json", %{show: json}), do: json

  def render("create.json", %{create: json}), do: json

  def render("update.json", %{update: json}), do: json

  def render("delete.json", %{delete: id}), do: %{"accepted" => "Customer #{id} has been deleted"}
  def render("delete.json", %{error: :not_found}), do: %{"errors" => "Customer not found"}

  def render("delete.json", %{error: id}),
    do: %{"errors" => "You cannot delete customer #{id}. It has associated invoices"}
end

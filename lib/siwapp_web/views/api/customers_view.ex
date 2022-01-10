defmodule SiwappWeb.Api.CustomersView do
  use JSONAPI.View, type: "customer"

  def fields,
    do: [
      :active,
      :contact_person,
      :deleted_at,
      :email,
      :id,
      :identification,
      :inserted_at,
      :invoicing_address,
      :meta_attributes,
      :name,
      :shipping_address,
      :updated_at
    ]

  def relationships do
    []
  end

  def render("create.json", %{create: json}) do
    json
  end

  def render("update.json", %{update: json}) do
    json
  end

  def render("delete.json", %{delete: id}), do: %{"accepted" => "Customer #{id} has been deleted"}
  def render("delete.json", %{not_found: id}), do: %{"errors" => "Customer #{id} not found"}

  def render("delete.json", %{error: id}),
    do: %{"errors" => "You cannot delete customer #{id}. It has associated invoices"}
end

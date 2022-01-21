defmodule SiwappWeb.Api.InvoicesView do
  use JSONAPI.View, type: "invoices"

  def fields,
    do: [
      :contact_person,
      :currency,
      :customer_id,
      :deleted_at,
      :deleted_number,
      :draft,
      :due_date,
      :email,
      :failed,
      :gross_amount,
      :id,
      :identification,
      :inserted_at,
      :invoicing_address,
      :items,
      :issue_date,
      :meta_attributes,
      :name,
      :net_amount,
      :notes,
      :number,
      :paid,
      :paid_amount,
      :recurring_invoices,
      :sent_by_email,
      :series_id,
      :shipping_address,
      :terms,
      :updated_at
    ]

  def relationships do
    [
      items: {SiwappWeb.Api.ItemsView, :include}
    ]
  end

  def render("index.json", %{list: json}), do: json

  def render("create.json", %{create: json}), do: json

  def render("show.json", %{show: json}), do: json

  def render("update.json", %{update: json}), do: json

  def render("delete.json", %{delete: id}), do: %{"accepted" => "Invoice #{id} has been deleted"}

  def render("delete.json", %{error: :not_found}), do: %{"errors" => "Invoice not found"}
end

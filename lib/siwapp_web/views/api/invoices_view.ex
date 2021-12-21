defmodule SiwappWeb.Api.InvoicesView do
  use JSONAPI.View, type: "invoices"

  def fields,
    do: [
      :contact_person,
      :currency,
      :customer_id,
      :customer,
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
      :series,
      :series_id,
      :shipping_address,
      :terms,
      :updated_at
    ]

  def relationships do
    [
      customer: {SiwappWeb.Api.CustomersView, :include},
      series: {SiwappWeb.Api.SeriesView, :include}
    ]
  end

  def render("index.json", %{list: json}) do
    json
  end

  def render("show.json", %{show: json}) do
    json
  end

  def render("create.json", %{create: json}) do
    json
  end
end

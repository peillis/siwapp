defmodule Siwapp.InvoicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Siwapp.Invoices` context.
  """

  alias Siwapp.Commons
  alias Siwapp.CustomersFixtures
  alias Siwapp.Invoices
  alias Siwapp.Repo

  def valid_item_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      quantity: 1,
      unitary_cost: 133,
      discount: 10,
      taxes: ["VAT", "RETENTION"]
    })
  end

  def valid_invoice_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: CustomersFixtures.unique_customer_name(),
      identification: CustomersFixtures.unique_customer_identification(),
      series_id: hd(Commons.list_series()).id,
      issue_date: Date.utc_today(),
      items: [valid_item_attributes()]
    })
  end

  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      attrs
      |> valid_invoice_attributes()
      |> Invoices.create()

    Repo.preload(invoice, [:customer, {:items, :taxes}, :series])
  end
end

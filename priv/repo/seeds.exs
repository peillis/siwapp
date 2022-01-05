# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Siwapp.Repo.insert!(%Siwapp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Siwapp.{Commons, Customers, Invoices}

customers = [
  %{name: "Pablo"},
  %{name: "Rodri"}
]

series = [
  %{name: "A-series", value: "A"}
]

taxes = [
  %{name: "VAT", value: 21, default: true},
  %{name: "RETENTION", value: -15}
]

items = [
  %{
    quantity: 2,
    unitary_cost: 10,
    discount: 5
  }
]

invoices = [
  %{
    name: "First_Invoice",
    gross_amount: 100,
    paid: true,
    sent_by_email: true,
    number: 1,
    issue_date: ~D[2021-10-08],
    due_date: ~D[2021-12-25],
    series_id: 1,
    customer_id: 1
  },
  %{
    name: "Second_Invoice",
    gross_amount: 400,
    number: 2,
    issue_date: ~D[2021-10-08],
    due_date: ~D[2021-12-21],
    series_id: 1,
    customer_id: 2
  },
  %{
    name: "Third_Invoice",
    gross_amount: 1200,
    sent_by_email: true,
    number: 3,
    issue_date: ~D[2021-10-08],
    due_date: ~D[2021-12-25],
    series_id: 1,
    customer_id: 1
  }
]

Enum.each(customers, &Customers.create(&1))
Enum.each(series, &Commons.create_series(&1))
Enum.each(taxes, &Commons.create_tax(&1))
Enum.each(invoices, &Invoices.create(&1))
Enum.each(items, &Invoices.create_item(&1))

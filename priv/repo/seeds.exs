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

alias Siwapp.{Commons, Customers, Invoices, RecurringInvoices}

today = Date.utc_today()

customers = [
  %{name: "Pablo"},
  %{name: "Rodri"}
]

series = [
  %{name: "A-series", code: "A"}
]

taxes = [
  %{name: "VAT", value: 21, default: true},
  %{name: "RETENTION", value: -15}
]

recurring_invoices = [
  %{
    period: 3,
    period_type: "Monthly",
    starting_date: ~D[2021-10-08],
    customer_id: 1,
    series_id: 1
  }
]

invoices = [
  %{
    name: "First_Invoice",
    gross_amount: 100,
    paid: true,
    sent_by_email: true,
    number: 1,
    issue_date: Date.add(today, -2),
    series_id: 1,
    customer_id: 1
  },
  %{
    name: "Second_Invoice",
    gross_amount: 400,
    number: 2,
    issue_date: today,
    due_date: Date.add(today, 30),
    series_id: 1,
    customer_id: 2
  },
  %{
    name: "Third_Invoice",
    gross_amount: 1200,
    sent_by_email: true,
    number: 3,
    issue_date: today,
    due_date: Date.add(today, 30),
    series_id: 1,
    customer_id: 1
  }
]

recurring_invoices = [
  %{
    period: 1,
    period_type: "Monthly",
    starting_date: ~D[2022-01-07],
    series_id: 1,
    customer_id: 1
  },
  %{
    period: 2,
    period_type: "Yearly",
    starting_date: ~D[2022-01-10],
    series_id: 1,
    customer_id: 2
  }
]

Enum.each(customers, &Customers.create(&1))
Enum.each(series, &Commons.create_series(&1))
Enum.each(taxes, &Commons.create_tax(&1))
Enum.each(invoices, &Invoices.create(&1))
Enum.each(recurring_invoices, &RecurringInvoices.create(&1))

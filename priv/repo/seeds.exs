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

alias Siwapp.{Commons, Customers, Invoices, RecurringInvoices, Settings, Templates}

today = Date.utc_today()

{:ok, file} = File.read("#{__DIR__}/fixtures/print_default.html.heex")

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
    terms: "A term",
    contact_person: "Gabriel",
    email: "info@doofinder.com",
    identification: "B000A2",
    invoicing_address: "Walabee 42, Sidney",
    paid: true,
    sent_by_email: true,
    number: 1,
    issue_date: Date.add(today, -2),
    due_date: Date.add(today, 30),
    series_id: 1,
    customer_id: 1,
    currency: "USD"
  },
  %{
    name: "Second_Invoice",
    gross_amount: 400,
    number: 2,
    issue_date: today,
    due_date: Date.add(today, 30),
    series_id: 1,
    customer_id: 2,
    currency: "USD"
  },
  %{
    name: "Third_Invoice",
    gross_amount: 1200,
    sent_by_email: true,
    number: 3,
    issue_date: today,
    due_date: Date.add(today, 30),
    series_id: 1,
    customer_id: 1,
    currency: "USD"
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

settings = [
  company: "Doofinder",
  company_vat_id: "1fg5t7",
  company_phone: "632778941",
  company_email: "demo@example.com",
  company_website: "www.mywebsite.com",
  currency: "USD",
  days_to_due: "0",
  company_address: "Newton Avenue, 32. NY",
  legal_terms: "Clauses of our contract"
]

templates = [
  %{
    name: "Print Default",
    template: file
  }
]

items = [
  %{
    quantity: 1,
    description: "first description",
    unitary_cost: 42_000
  }
]

Enum.each(customers, &Customers.create(&1))
Enum.each(series, &Commons.create_series(&1))
Enum.each(taxes, &Commons.create_tax(&1))
Enum.each(invoices, &Invoices.create(&1))
Enum.each(recurring_invoices, &RecurringInvoices.create(&1))
Enum.each(settings, &Settings.create(&1))
Enum.each(templates, &Templates.create(&1))
Enum.each(items, &Invoices.create_item(Invoices.get!(1), &1))

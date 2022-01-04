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
alias Siwapp.Invoices
alias Siwapp.Customers
alias Siwapp.Commons

customers = [
  %{
    name: "Pablo"
  },
  %{
    name: "Rodri"
  }
]

series = [
  %{
    "name" => "A-series",
    "value" => "A"
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

Enum.each(customers, fn customer ->
  Customers.create(customer)
end)

Enum.each(series, fn serie ->
  Commons.create_series(serie)
end)

Enum.each(invoices, fn invoice ->
  Invoices.create(invoice)
end)

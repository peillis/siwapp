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

alias Siwapp.{
  Repo,
  Accounts,
  Commons,
  Customers,
  Invoices,
  RecurringInvoices,
  Settings,
  Templates
}

models = [
  Commons.Series,
  Commons.Tax,
  Customers.Customer,
  Invoices.Invoice,
  Invoices.Item,
  RecurringInvoices.RecurringInvoice,
  Settings.Setting
]

Enum.each(models, &Repo.delete_all(&1))

# SEEDING ACCOUNTS
Enum.each(1..3, fn _ ->
  Accounts.register_user(%{
    email: Faker.Internet.email(),
    password: Faker.String.base64(12)
  })
end)

# SEEDING SETTINGS
settings = [
  company: "Doofinder",
  company_vat_id: "1fg5t7",
  company_phone: "632778941",
  company_email: "demo@example.com",
  company_website: "www.mywebsite.com",
  currency: "USD",
  days_to_due: "#{Faker.random_between(0, 5)}",
  company_address: "Newton Avenue, 32. NY",
  legal_terms: "Clauses of our contract"
]

Enum.each(settings, &Settings.create(&1))

# SEEDING TEMPLATES

{:ok, print_default} = File.read("#{__DIR__}/fixtures/print_default.html.heex")
{:ok, email_default} = File.read("#{__DIR__}/fixtures/email_default.html.heex")

Templates.create(%{
  name: "Print Default",
  template: print_default
})

{:ok, email_template} =
  Templates.create(%{
    name: "Email Default",
    template: email_default,
    subject: "Payment Confirmation: <%= invoice %> "
  })

Templates.set_default(:email, email_template)

# SEEDING SERIES
series = [
  %{name: "A-series", code: "A"},
  %{name: "B-series", code: "B"},
  %{name: "C-series", code: "C"}
]

Enum.each(series, &Commons.create_series(&1))

# SEEDING TAXES
taxes = [
  %{name: "VAT", value: 21, default: true},
  %{name: "RETENTION", value: -15}
]

Enum.each(taxes, &Commons.create_tax(&1))

# SEEDING CUSTOMERS
customers = Enum.map(0..15, fn _i -> %{name: Faker.Person.name(), id: Faker.Code.issn()} end)

Enum.each(
  customers,
  &Customers.create(%{
    name: &1.name,
    identification: &1.id,
    email: Faker.Internet.email(),
    contact_person: Faker.Person.name(),
    invoicing_address:
      "#{Faker.Address.street_address()}\n#{Faker.Address.postcode()} #{Faker.Address.country()}"
  })
)

# SEEDING INVOICES
currencies = ["USD", "USD", "USD", "EUR", "GBP"]
booleans = [true, false]

invoices =
  Enum.map(0..30, fn _i ->
    %{customer: Enum.random(customers), issue_date: Faker.Date.backward(31)}
  end)

Enum.each(
  invoices,
  &Invoices.create(%{
    name: &1.customer.name,
    identification: &1.customer.id,
    paid: Enum.random(booleans),
    sent_by_email: Enum.random(booleans),
    issue_date: &1.issue_date,
    due_date: Date.add(&1.issue_date, Faker.random_between(1, 31)),
    series_id: Faker.random_between(1, 3),
    currency: Enum.random(currencies),
    items: [
      %{
        quantity: Faker.random_between(1, 2),
        description: "#{Faker.App.name()} App Development",
        unitary_cost: Faker.random_between(10_000, 1_000_000),
        taxes: ["VAT", "RETENTION"]
      }
    ]
  })
)

# SEEDING RECURRING INVOICES
today = Date.utc_today()

recurring_invoices = [
  %{
    name: Faker.Person.name(),
    period: 3,
    period_type: "Daily",
    starting_date: Date.add(today, -30),
    series_id: 1,
    customer_id: 1
  },
  %{
    name: Faker.Person.name(),
    period: 2,
    period_type: "Monthly",
    starting_date: Date.add(today, -60),
    series_id: 2,
    customer_id: 2,
    items: %{
      "0" => %{
        "description" => "description",
        "quantity" => 1,
        "unitary_cost" => 0,
        "discount" => 0,
        "taxes" => ["RETENTION"]
      }
    }
  },
  %{
    name: Faker.Person.name(),
    period: 1,
    period_type: "Yearly",
    starting_date: Date.add(today, -400),
    series_id: 3,
    customer_id: 3,
    items: %{
      "0" => %{
        "description" => "description",
        "quantity" => 1,
        "unitary_cost" => 0,
        "discount" => 0,
        "taxes" => ["VAT"]
      }
    }
  }
]

Enum.each(recurring_invoices, &RecurringInvoices.create(&1))

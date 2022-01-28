defmodule Siwapp.InvoiceTest do
  use Siwapp.DataCase

  alias Siwapp.Commons
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.Settings

  import Siwapp.InvoicesFixtures
  import Siwapp.SettingsFixtures
  import Siwapp.CommonsFixtures

  setup do
    {:ok, series} = Commons.create_series(%{name: "A-Series", code: "A-"})
    {:ok, tax1} = Commons.create_tax(%{name: "VAT", value: 21, default: true})
    {:ok, tax2} = Commons.create_tax(%{name: "RETENTION", value: -15})
    settings_fixture()

    %{series_id: series.id, taxes: [tax1, tax2]}
  end

  describe "saving restrictions, and draft exception: " do
    test "an invoice cannot be saved if does not have required fields" do
      changeset = Invoice.changeset(%Invoice{}, %{name: "Melissa"})

      assert %{series_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "an invoice can be saved if it has all the required fields", %{series_id: series_id} do
      changeset =
        Invoice.changeset(%Invoice{}, %{
          name: "Melissa",
          series_id: series_id
        })

      assert changeset.valid?
    end

    test "a draft doesn't need series_id nor issue_date" do
      changeset = Invoice.changeset(%Invoice{}, %{name: "Melissa", draft: true})

      assert changeset.valid?
    end

    test "a draft can't have number" do
      changeset = Invoice.changeset(%Invoice{}, %{name: "Nuria", draft: true, number: 3})

      assert %{number: ["can't assign number to draft"]} = errors_on(changeset)
    end
  end

  describe "limited draft enablement: " do
    test "an existing regular invoice cannot be converted to draft" do
      invoice = invoice_fixture(draft: false)
      changeset = Invoice.changeset(invoice, %{draft: true})

      assert %{draft: ["can't be enabled, invoice is not new"]} = errors_on(changeset)
    end

    test "an existing draft can be re-marked as draft" do
      invoice = invoice_fixture(draft: true)
      changeset = Invoice.changeset(invoice, %{draft: true})

      assert changeset.valid?
    end

    test "a new invoice can be saved as draft" do
      assert {:ok, %Invoice{}} = Invoices.create(valid_invoice_attributes(%{draft: true}))
    end
  end

  describe "total amounts for an invoice: " do
    setup do
      invoice =
        invoice_fixture(
          items: [
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10,
              taxes: ["VAT"]
            },
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10,
              taxes: ["VAT", "RETENTION"]
            }
          ]
        )

      %{invoice: invoice}
    end

    test "total net amount of an invoice without items is 0" do
      invoice = invoice_fixture(items: [])

      assert invoice.net_amount == 0
    end

    test "total taxes amounts of an invoice without items is an empty map" do
      invoice = invoice_fixture(items: [])

      assert invoice.taxes_amounts == %{}
    end

    test "total taxes amounts of an invoice whose items don't have any taxes associated is an empty map" do
      invoice =
        invoice_fixture(
          items: [valid_item_attributes(taxes: []), valid_item_attributes(taxes: [])]
        )

      assert invoice.taxes_amounts == %{}
    end

    test "total gross amount of an invoice without items is 0" do
      invoice = invoice_fixture(items: [])

      assert invoice.gross_amount == 0
    end

    test "Total net amount is the rounded sum of the net amounts of each item", %{
      invoice: invoice
    } do
      # 133-(133*(10/100)) = 119.70 (net_amount per item)
      # 119.70*2 = 239.40 (total net_amount)
      assert invoice.net_amount == 239
    end

    test "Total taxes amounts is a map with the total amount per tax", %{invoice: invoice} do
      # 119.70 (net_amount per item)
      # 119.70*(21/100) = 25.137 (VAT per item)
      # 119.70*(-15/100) = -17.955 (RETENTION for 2nd item)
      assert invoice.taxes_amounts == %{"RETENTION" => -17.955, "VAT" => 50.274}
    end

    test "Total gross amount is the rounded sum of the total net amount and the taxes amounts", %{
      invoice: invoice
    } do
      # 239 (total net_amount)
      # %{"RETENTION" => -17.955, "VAT" => 50.274} (total taxes amounts)
      # 239 + 50.274 - 17.955 = 271.319 (total gross_amount)
      assert invoice.gross_amount == 271
    end
  end

  describe "default dates for an invoice: " do
    setup do
      %{today: Date.utc_today()}
    end

    test "Issue date always has a value when created" do
      assert invoice_fixture().issue_date != nil
    end

    test "Due date always has a value when created" do
      assert invoice_fixture().due_date != nil
    end

    test "Issue date is today if none is provided", %{today: today} do
      assert invoice_fixture().issue_date == today
    end

    test "If you provide an issue date, that one is set" do
      invoice = invoice_fixture(%{issue_date: ~D[2022-12-12]})

      assert invoice.issue_date == ~D[2022-12-12]
    end

    test "Due date is today + 'Days to due' value set in Settings", %{today: today} do
      Settings.apply_user_settings(%{"days_to_due" => "5"})

      assert invoice_fixture().due_date == Date.add(today, 5)
    end
  end

  describe "If number is introduced manually, it's respected" do
    test "Updating invoice to new series assigning number manually preserves that number" do
      series = series_fixture()
      invoice = invoice_fixture(%{series_id: series.id})
      new_series = series_fixture(%{first_number: 5})

      {:ok, invoice} =
        Invoices.update(invoice, %{
          series_id: new_series.id,
          number: 20
        })

      assert invoice.number == 20
    end

    test "If number's already assigned, changeset isn't valid" do
      series = series_fixture()
      _invoice = invoice_fixture(%{series_id: series.id, number: 3})
      changeset = Invoice.changeset(%Invoice{}, %{series_id: series.id, number: 3})

      assert changeset.valid? == false
    end
  end

  describe "Automatical number assignment when no number is provided" do
    test "If there aren't associated series yet there's no number" do
      changeset = Invoice.changeset(%Invoice{})
      assert is_nil(Ecto.Changeset.get_field(changeset, :number))
    end

    test "If draft, no number is assigned" do
      changeset = Invoice.changeset(%Invoice{}, %{draft: true})

      assert is_nil(Ecto.Changeset.get_field(changeset, :number))
    end

    test "Creation of first invoice for a given series. Number is series' first number" do
      series = series_fixture(%{first_number: 1})
      invoice = invoice_fixture(%{series_id: series.id})
      assert invoice.number == 1
    end

    test "Creation of invoice in series that has already associated invoices. Number is next of greatest invoice's number in series" do
      series = series_fixture(%{first_number: 2})
      _invoice1 = invoice_fixture(%{series_id: series.id, number: 5})
      _invoice2 = invoice_fixture(%{series_id: series.id, number: 1})
      invoice3 = invoice_fixture(%{series_id: series.id})
      assert invoice3.number == 6
    end

    test "Updating invoice changing series. Number assignment to first invoice associated to that series behaves like creation" do
      series = series_fixture()
      invoice1 = invoice_fixture(%{series: series.id, number: 7})
      new_series = series_fixture(%{first_number: 3})
      {:ok, invoice1} = Invoices.update(invoice1, %{series_id: new_series.id})
      assert invoice1.number == 3
    end

    test "Updating invoice changing series. Number is next of greatest invoice's number in series" do
      series = series_fixture()
      invoice1 = invoice_fixture(%{series_id: series.id})
      new_series = series_fixture(%{first_number: 4})
      _invoice2 = invoice_fixture(%{series_id: new_series.id, number: 20})
      {:ok, invoice1} = Invoices.update(invoice1, %{series_id: new_series.id})
      assert invoice1.number == 21
    end
  end
end

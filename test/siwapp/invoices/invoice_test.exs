defmodule Siwapp.InvoiceTest do
  use Siwapp.DataCase

  alias Siwapp.Commons
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice

  import Siwapp.InvoicesFixtures

  setup do
    {:ok, series} = Commons.create_series(%{name: "A-Series", code: "A-"})
    {:ok, tax1} = Commons.create_tax(%{name: "VAT", value: 21, default: true})
    {:ok, tax2} = Commons.create_tax(%{name: "RETENTION", value: -15})
    %{series_id: series.id, series: series, taxes: [tax1, tax2]}
  end

  describe "saving restrictions, and draft exception: " do
    test "an invoice cannot be saved if does not have required fields" do
      changeset = Invoice.changeset(%Invoice{}, %{name: "Melissa"})

      assert %{series_id: ["can't be blank"]} = errors_on(changeset)
      assert %{issue_date: ["can't be blank"]} = errors_on(changeset)
    end

    test "an invoice can be saved if it has all the required fields", %{series_id: series_id} do
      changeset =
        Invoice.changeset(%Invoice{}, %{
          name: "Melissa",
          series_id: series_id,
          issue_date: Date.utc_today()
        })

      assert changeset.valid?
    end

    test "a draft is valid always" do
      changeset = Invoice.changeset(%Invoice{}, %{name: "Melissa", draft: true})

      assert changeset.valid?
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

  describe "Number assignment when number isn't changed" do
    test "If there aren't associated series there's no number" do
      changeset = Invoice.changeset(%Invoice{})
      assert is_nil(Map.get(changeset.changes, :number))
    end

    test "Creation of first invoice for a given series. Number is series' first number" do
      series = new_series()
      invoice = populate_series(series)
      assert invoice.number == series.first_number
    end

    test "Creation of invoice in already populated series. Number is next of greatest invoice's number in series" do
      series = already_populated_series()
      invoice1 = populate_series(series, %{number: series.first_number + 1})
      invoice2 = populate_series(series)
      assert invoice2.number == invoice1.number + 1
    end

    test "Updating invoice to new series, number assignment behaves like creation of invoice in series" do
      invoice1 = invoice_fixture()
      series = new_series()
      {:ok, invoice1} = Invoices.update(invoice1, %{series_id: series.id})
      invoice2 = invoice_fixture()
      {:ok, invoice2} = Invoices.update(invoice2, %{series_id: series.id})
      assert invoice1.number == series.first_number
      assert invoice2.number == invoice1.number + 1
    end
  end

  describe "Number assignment does nothing when number is changed" do
    test "If there are changes to number, they are respected", %{series: series1} do
      series2 = new_series()

      {:ok, invoice1} =
        Invoices.update(invoice_fixture(), %{
          series_id: series2.id,
          number: series1.first_number + 10
        })

      invoice2 = invoice_fixture()

      {:ok, invoice2} =
        Invoices.update(invoice2, %{series_id: series2.id, number: invoice1.number + 10})

      assert invoice1.number == series1.first_number + 10
      assert invoice2.number == invoice1.number + 10
    end
  end
end

defmodule Siwapp.InvoiceTest do
  use Siwapp.DataCase

  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice

  alias Siwapp.Commons

  describe "Saving restrictions, and draft exception" do
    test "An invoice cannot be saved if does not have required fields" do
      changeset = Invoice.changeset(%Invoice{}, %{name: "Melissa"})

      assert %{series_id: ["can't be blank"]} = errors_on(changeset)
      assert %{issue_date: ["can't be blank"]} = errors_on(changeset)
    end

    test "An invoice can be saved if it has all the required fields" do
      changeset =
        Invoice.changeset(%Invoice{}, %{
          name: "Melissa",
          series_id: 1,
          issue_date: Date.utc_today()
        })

      assert changeset.valid?
    end

    test "A draft is valid always" do
      changeset = Invoice.changeset(%Invoice{}, %{name: "Melissa", draft: true})

      assert changeset.valid?
    end
  end

  describe "Limited draft enablement" do
    test "An existing regular invoice cannot be converted to draft" do
      {:ok, series} = Commons.create_series(%{name: "A-Series", code: "A-"})

      {:ok, invoice} =
        Invoices.create(%{name: "Melissa", series_id: series.id, issue_date: Date.utc_today()})

      changeset =
        Repo.preload(invoice, :items)
        |> Invoice.changeset(%{draft: true})

      assert %{draft: ["can't be enabled, invoice is not new"]} = errors_on(changeset)
    end

    test "An existing draft can be re-marked as draft" do
      {:ok, invoice} = Invoices.create(%{name: "Melissa", draft: true})

      changeset =
        Repo.preload(invoice, :items)
        |> Invoice.changeset(%{draft: true})

      assert changeset.valid?
    end

    test "A new invoice can be saved as draft" do
      assert {:ok, %Invoice{}} = Invoices.create(%{name: "Melissa", draft: true})
    end
  end

  describe "Total amounts for an invoice" do
    test "Total net amount of an invoice without items is 0" do
      {:ok, invoice} = Invoices.create(%{name: "Melissa", draft: true})

      assert invoice.net_amount == 0
    end

    test "Total taxes amounts of an invoice without items is an empty map" do
      {:ok, invoice} = Invoices.create(%{name: "Melissa", draft: true})

      assert invoice.taxes_amounts == %{}
    end

    test "Total taxes amounts of an invoice whose items don't have any taxes associated is an empty map" do
      {:ok, invoice} = Invoices.create(%{name: "Melissa", draft: true})

      Invoices.create_item(invoice, %{quantity: 1, unitary_cost: 133, discount: 10})

      assert invoice.taxes_amounts == %{}
    end

    test "Total gross amount of an invoice without items is 0" do
      {:ok, invoice} = Invoices.create(%{name: "Melissa", draft: true})

      assert invoice.gross_amount == 0
    end

    test "Total net amount is the rounded sum of the net amounts of each item" do
      {:ok, invoice} =
        Invoices.create(%{
          name: "Melissa",
          draft: true,
          items: [
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10
            },
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10
            }
          ]
        })

      # 133-(133*(10/100)) = 119.70 (net_amount per item)
      # 119.70*2 = 239.40 (total net_amount)
      assert invoice.net_amount == 239
    end

    test "Total taxes amounts is a map with the total amount per tax" do
      IO.puts "ESTE"

      {:ok, invoice} =
        Invoices.create(%{
          name: "Melissa",
          draft: true,
          items: [
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10,
              taxes: [%{name: "VAT"}]
            },
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10,
              taxes: [%{name: "VAT"}, %{name: "RETENTION"}]
            }
          ]
        })

      # 119.70 (net_amount per item)
      # 119.70*(21/100) = 25.137 (VAT per item)
      # 119.70*(-15/100) = -17.955 (RETENTION for 2nd item)
      assert invoice.taxes_amounts == %{"RETENTION" => -17.955, "VAT" => 50.274}
    end

    test "Total gross amount is the rounded sum of the total net amount and the taxes amounts" do
      {:ok, invoice} =
        Invoices.create(%{
          name: "Melissa",
          draft: true,
          items: [
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10,
              taxes: [%{name: "VAT"}]
            },
            %{
              quantity: 1,
              unitary_cost: 133,
              discount: 10,
              taxes: [%{name: "VAT"}, %{name: "RETENTION"}]
            }
          ]
        })

      # 239 (total net_amount)
      # %{"RETENTION" => -17.955, "VAT" => 50.274} (total taxes amounts)
      # 239 + 2*25.137 - 17.955 = 271.319 (total gross_amount)
      assert invoice.gross_amount == 271
    end
  end
end

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
      {:ok, series} = Commons.create_series(%{name: "A-Series", value: "A-"})

      {:ok, invoice} =
        Invoices.create(%{name: "Melissa", series_id: series.id, issue_date: Date.utc_today()})

      changeset = Invoice.changeset(invoice, %{draft: true})

      assert %{draft: ["can't be enabled, invoice is not new"]} = errors_on(changeset)
    end

    test "An existing draft can be re-marked as draft" do
      {:ok, invoice} = Invoices.create(%{name: "Melissa", draft: true})
      changeset = Invoice.changeset(invoice, %{draft: true})

      assert changeset.valid?
    end

    test "A new invoice can be saved as draft" do
      assert {:ok, %Invoice{}} = Invoices.create(%{name: "Melissa", draft: true})
    end
  end
end

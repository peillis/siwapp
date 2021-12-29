defmodule Siwapp.InvoiceTest do
  use Siwapp.DataCase

  alias Siwapp.Invoices.Invoice

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
end

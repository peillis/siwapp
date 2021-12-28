defmodule Siwapp.InvoicesTest do
  use Siwapp.DataCase

  alias Siwapp.Invoices.Invoice
  alias Siwapp.Customers
  alias Siwapp.Commons

  describe "saving restrictions" do
    test "not draft cannot be saved if does not have an associated series" do
      {:ok, c} = Customers.create(%{name: "James"})

      changeset =
        Invoice.changeset(%Invoice{}, %{
          name: "Melissa",
          customer_id: c.id,
          draft: false
        })

      assert %{series_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "not draft can be saved if has an associated series" do
      {:ok, c} = Customers.create(%{name: "Melissa"})
      {:ok, s} = Commons.create_series(%{value: "L-"})

      changeset =
        Invoice.changeset(%Invoice{}, %{
          name: "Melissa",
          customer_id: c.id,
          series_id: s.id,
          draft: false
        })

      assert changeset.valid?
    end

    test "draft can be saved if does not have an associated series" do
      {:ok, c} = Customers.create(%{name: "Mery"})

      changeset =
        Invoice.changeset(%Invoice{}, %{
          name: "Melissa",
          customer_id: c.id,
          draft: true
        })

      assert changeset.valid?
    end
  end
end

defmodule Siwapp.CommonsTest do
  use Siwapp.DataCase

  import Siwapp.CommonsFixtures
  import Siwapp.InvoicesFixtures
  import Siwapp.RecurringInvoicesFixtures
  import Siwapp.SettingsFixtures

  alias Siwapp.Commons
  alias Siwapp.Commons.Series
  alias Siwapp.Commons.Tax

  setup do
    _series = series_fixture(%{name: "Default series", code: "D-"})
    _tax1 = taxes_fixture(%{name: "VAT", value: 21, default: true})
    _tax2 = taxes_fixture(%{name: "RETENTION", value: -15})
    settings_fixture()

    %{default_series: Commons.get_default_series()}
  end

  describe "series creation" do
    test "series must have a code" do
      changeset = Series.changeset(%Series{}, %{name: "A- series"})
      assert %{code: ["can't be blank"]} = errors_on(changeset)
    end

    test "series can have no name" do
      assert {:ok, _series} = Commons.create_series(%{code: "A-"})
    end

    test "series are set as enabled but not as default automatically" do
      {:ok, series} = Commons.create_series(%{code: "A-"})

      assert series.enabled and not series.default
    end

    test "series can't be marked as default from creation" do
      {:error, msg} = Commons.create_series(valid_series_attributes(%{default: true}))

      assert ^msg =
               "You cannot directly assign the default key. Use the change_default_series/1 function instead."
    end

    test "series are unique by name and enabled combination" do
      {:ok, _series} = Commons.create_series(%{name: "A- series", code: "A"})
      {:error, changeset} = Commons.create_series(%{name: "A- series", code: "A"})
      {:ok, _series} = Commons.create_series(%{name: "A- series", code: "A", enabled: false})

      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "series updating" do
    test "if one series is set to default, the rest will be not default" do
      series = series_fixture()
      _series1 = series_fixture()
      _series2 = series_fixture()

      {:ok, default_series} = Commons.change_default_series(series)

      assert default_series.default and
               Enum.reduce(Commons.list_series(), true, fn series, acc ->
                 acc && if series == default_series, do: series.default, else: not series.default
               end)
    end
  end

  describe "series deletion" do
    test "if series is default can't be deleted", %{default_series: default_series} do
      {:error, msg} = Commons.delete_series(default_series)
      assert msg == "The series you're aiming to delete is the default series. \
      Change the default series first"
    end

    test "if there are invoices or recurring_invoices associated to series, can't be destroyed" do
      series1 = series_fixture()
      series2 = series_fixture()

      _invoice = invoice_fixture(%{series_id: series1.id})
      _recurring_invoice = recurring_invoice_fixture(%{series_id: series2.id})
      {:error, msg1} = Commons.delete_series(series1)
      {:error, msg2} = Commons.delete_series(series2)

      assert msg1 == "It's forbidden to delete a series with associated invoices"
      assert msg2 == "It's forbidden to delete a series with associated invoices"
    end
  end

  ## TAXES ##

  describe "taxes creation" do
    test "taxes must have a name and a value" do
      changeset = Tax.changeset(%Tax{}, %{})
      assert %{name: ["can't be blank"], value: ["can't be blank"]} = errors_on(changeset)
    end

    test "taxes are set as enabled but not as default automatically" do
      tax = taxes_fixture()

      assert tax.enabled and not tax.default
    end

    test "taxes are unique by name and enabled combination" do
      _tax = taxes_fixture(%{name: "Example"})
      {:error, changeset} = Commons.create_tax(%{name: "Example", value: 20})
      _tax = taxes_fixture(%{name: "Example", enabled: false})

      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end

    test "taxes aren't case sensitive since their name's stored always uppercase" do
      tax = taxes_fixture(%{name: "ExAmpLe"})
      assert tax.name == "EXAMPLE"
    end
  end

  describe "taxes deletion" do
    test "if there are invoices or recurring_invoices associated to tax, can't be destroyed" do
      tax1 = taxes_fixture(%{name: "Example1"})
      tax2 = taxes_fixture(%{name: "Example2"})

      _invoice = invoice_fixture(%{items: [valid_item_attributes(taxes: ["Example1"])]})

      items_rec_inv = %{
        "0" => %{
          "quantity" => 1,
          "discount" => 0,
          "description" => "desc",
          "unitary_cost" => 1_000,
          "taxes" => ["Example2"]
        }
      }

      _recurring_invoice = recurring_invoice_fixture(%{items: items_rec_inv})
      {:error, msg1} = Commons.delete_tax(tax1)
      {:error, msg2} = Commons.delete_tax(tax2)

      assert msg1 == "It's forbidden to delete a tax with associated invoices/recurring invoices"
      assert msg2 == "It's forbidden to delete a tax with associated invoices/recurring invoices"
    end
  end
end

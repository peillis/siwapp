defmodule Siwapp.RecurringInvoicesTest do
  use Siwapp.DataCase

  import Siwapp.RecurringInvoicesFixtures
  alias Siwapp.RecurringInvoices

  setup do
    {:ok, series} = Commons.create_series(%{name: "A-Series", code: "A-"})
  end

  describe "invoices_to_generate/1" do
    test ""
  end

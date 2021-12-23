defmodule Siwapp.ItemsTest do
  use Siwapp.DataCase

  alias Siwapp.Commons.Tax
  alias Siwapp.Invoices.Item

  describe "base_amount(item) Result of the multiply between the quantity and the unitary cost of an item" do
    test "return the base amount if quantity and unitary cost are well defined" do
      item = %Item{quantity: 2, unitary_cost: 10}
      assert Item.base_amount(item) == 20
    end
  end

  describe "discount_amount(item) Total discount amount given a discount" do
    test "return the discount amount if discount is well defined" do
      assert Item.discount_amount(%Item{quantity: 2, unitary_cost: 10, discount: 50}) == 10
    end
  end

  describe "net_amount(item) Substraction between base amount and discount amount" do
    test "return the net amount if either base_amount/1 and discount_amount/1 does not return errors" do
      assert Item.net_amount(%Item{quantity: 2, unitary_cost: 10, discount: 50}) == 10
    end
  end

  describe "taxes_amount(item) Takes the taxes value for those taxes associated to the correspondent item and calculate the taxes amount" do
    test "return a list if a tax or a group of tax exists" do
      assert Item.taxes_amount(%Item{
               taxes: [%Tax{id: 1, value: 20}],
               quantity: 2,
               unitary_cost: 10,
               discount: 50
             }) == [%{1 => 2}]
    end
  end
end

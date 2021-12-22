defmodule Siwapp.ItemsTest do
  use Siwapp.DataCase

  alias Siwapp.Commons.Tax
  alias Siwapp.Invoices.Item

  describe "base_amount(item) Result of the multiply between the quantity and the unitary cost of an item" do
    test "does not return the base amount if quantity is a number less than 1"
    %Item{quantity: -1, unitary_cost: 10} = item
    assert Item.base_amount(item) == quantity: {"must be greater than or equal to 1"}

    test "return the base amount if quantity and unitary cost are well defined"
    %Item{quantity: 1, unitary_cost: 10} = item
    assert Item.base_amount(item) == :base_amount
  end

  describe "discount_amount(item) Total discount amount given a discount" do
    test "does not return the discount amount if discount is less than 0"
    %Item{quantity: 1, unitary_cost: 10, discount: -1} = item
    assert Item.discount_amount(item) == discount: {"must be greater than or equal to 0"}

    test "does not return the discount amount if discount is greater than 100"
    %Item{quantity: 1, unitary_cost: 10, discount: 101} = item
    assert Item.discount_amount(item) == discount: {"must be less than or equal to 100"}

    test "return the discount amount if discount is well defined"
    %Item{quantity: 1, unitary_cost: 10, discount: 101} = item
    assert Item.discount_amount(item) == :discount_amount

  end

  describe "net_amount(item) Substraction between base amount and discount amount" do
    test "return the net amount if either base_amount/1 and discount_amount/1 does not return errors"
    %Item{discount_amount: 0.5, base_amount: 1} = item
    assert Item.net_amount(item) == :net_amount
  end

  describe "taxes_amount(item) Takes the taxes value for those taxes associated to the correspondent item and calculate the taxes amount" do
    test "does not return the taxes amount if there is no taxes loaded before"
    %Item{taxes: #Ecto.Association.NotLoaded <association :taxes is not loaded>}
    assert Item.taxes_amount(item) == :error

    test "return an empty list if the taxes are being loaded before and are an empty list"
    %Item{taxes: []}
    assert Item.taxes_amount(item) == []

    test "return a list if a tax or a group of tax exists"
    %Item{taxes: [%Tax{}]}
    assert Item.taxes_amount(item) == [:taxes_amount]
  end

  describe "gross_amount(item) Sume betwwen net_amount and taxes_amount" do
    test "return the gross amount if either net_amount/1 and taxes_amount/1 does not return errors"
    %Item{taxes_amount: [], net_amount: 1} = item
    assert Item.gross_amount(item) == :gross_amount
  end
end

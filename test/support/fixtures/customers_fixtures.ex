defmodule Siwapp.CustomersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Siwapp.Customers` context.
  """
  def unique_customer_name, do: "#{System.unique_integer()}"

  def unique_customer_identification, do: "#{System.unique_integer()}"

  def valid_customer_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_customer_name(),
      identification: unique_customer_identification()
    })
  end

  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> valid_customer_attributes()
      |> Siwapp.Customers.create()

    customer
  end
end

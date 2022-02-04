defmodule Siwapp.CommonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Siwapp.Commons` context.
  """

  alias Siwapp.Commons

  def unique_series_name, do: "#{System.unique_integer()}"

  def unique_series_code, do: "#{System.unique_integer()}"

  def unique_taxes_name, do: "#{System.unique_integer()}"

  def unique_taxes_value, do: :rand.uniform(30)

  def series_fixture(attrs \\ %{}) do
    {:ok, series} =
      attrs
      |> valid_series_attributes()
      |> Commons.create_series()

    series
  end

  def valid_series_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_series_name(),
      code: unique_series_code(),
      first_number: 1
    })
  end

  def taxes_fixture(attrs \\ %{}) do
    {:ok, tax} =
      attrs
      |> valid_taxes_attributes()
      |> Commons.create_tax()

    tax
  end

  def valid_taxes_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_taxes_name(),
      value: unique_taxes_value()
    })
  end
end

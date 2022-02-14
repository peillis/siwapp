defmodule SiwappWeb.Resolvers.Invoice do
  @moduledoc false

  alias Siwapp.Invoices
  alias SiwappWeb.PageView
  alias SiwappWeb.Resolvers.Errors

  def list(%{customer_id: customer_id, limit: limit, offset: offset}, _resolution) do
    invoices =
      Invoices.list(
        limit: limit,
        offset: offset,
        preload: [:items],
        filters: [customer_id: customer_id]
      )
      |> Enum.map(&set_correct_units/1)

    {:ok, invoices}
  end

  def list(%{limit: limit, offset: offset}, _resolution) do
    invoices =
      Invoices.list(limit: limit, offset: offset, preload: [:items])
      |> Enum.map(&set_correct_units/1)

    {:ok, invoices}
  end

  def create(args, _resolution) do
    case Invoices.create(args) do
      {:ok, invoice} ->
        {:ok, set_correct_units(invoice)}

      {:error, changeset} ->
        {:error, message: "Failed!", details: Errors.extract(changeset)}
    end
  end

  defp set_correct_units(invoice) do
    Enum.reduce([:net_amount, :gross_amount, :paid_amount], invoice, fn key, invoice ->
      Map.update(invoice, key, 0, fn existing_value ->
        PageView.set_currency(existing_value, invoice.currency, symbol: false)
      end)
    end)
  end
end

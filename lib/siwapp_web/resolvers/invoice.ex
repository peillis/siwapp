defmodule SiwappWeb.Resolvers.Invoice do
  @moduledoc false

  alias Siwapp.Invoices
  alias SiwappWeb.PageView
  alias SiwappWeb.Resolvers.Errors

  def list(%{customer_id: customer_id}, _resolution) do
    invoice =
      Invoices.list_by([{:customer_id, customer_id}])
      |> list_correct_units()

    {:ok, invoice}
  end

  def list(_, _resolution) do
    {:ok, list_correct_units(Invoices.list())}
  end

  def create(args, _resolution) do
    case Invoices.create(args) do
      {:ok, invoice} ->
        {:ok, set_correct_units(invoice)}

      {:error, changeset} ->
        {:error, message: "Failed!", details: Errors.extract(changeset)}
    end
  end

  defp list_correct_units(invoices) do
    Enum.map(invoices, fn i -> set_correct_units(i) end)
  end

  defp set_correct_units(invoice) do
    Enum.reduce([:net_amount, :gross_amount, :paid_amount], invoice, fn key, invoice ->
      Map.update(invoice, key, 0, fn existing_value ->
        PageView.set_currency(existing_value, invoice.currency, symbol: false)
      end)
    end)
  end
end

defmodule SiwappWeb.Resolvers.Invoice do
  @moduledoc false

  alias Siwapp.Invoices
  alias SiwappWeb.PageView
  alias SiwappWeb.Resolvers.Errors

  @spec list(map(), Absinthe.Resolution.t()) :: {:ok, [Invoices.Invoice.t()]}
  def list(%{customer_id: customer_id, limit: limit, offset: offset}, _resolution) do
    invoices =
      Invoices.list(
        limit: limit,
        offset: offset,
        preload: [:items, :payments],
        filters: [customer_id: customer_id]
      )

    invoices = Enum.map(invoices, &set_correct_units/1)

    {:ok, invoices}
  end

  def list(%{limit: limit, offset: offset}, _resolution) do
    invoices = Invoices.list(limit: limit, offset: offset, preload: [:items, :payments])
    invoices = Enum.map(invoices, &set_correct_units/1)

    {:ok, invoices}
  end

  @spec create(map(), Absinthe.Resolution.t()) :: {:error, map()} | {:ok, Invoices.Invoice.t()}
  def create(args, _resolution) do
    args = maybe_change_meta_attributes(args, nil)

    case Invoices.create(args) do
      {:ok, invoice} ->
        {:ok, set_correct_units(invoice)}

      {:error, changeset} ->
        {:error, message: "Failed!", details: Errors.extract(changeset)}
    end
  end

  @spec update(map(), Absinthe.Resolution.t()) :: {:error, map()} | {:ok, Invoices.Invoice.t()}
  def update(%{id: id} = params, _resolution) do
    invoice = Invoices.get(id, preload: [:customer, {:items, :taxes}, :payments, :series])

    params = maybe_change_meta_attributes(params, invoice.meta_attributes)

    if is_nil(invoice) do
      {:error, message: "Failed!", details: "Invoice not found"}
    else
      case Invoices.update(invoice, params) do
        {:ok, invoice} ->
          {:ok, set_correct_units(invoice)}

        {:error, changeset} ->
          {:error, message: "Failed!", details: Errors.extract(changeset)}
      end
    end
  end

  @spec delete(map(), Absinthe.Resolution.t()) :: {:error, map()} | {:ok, Invoices.Invoice.t()}
  def delete(%{id: id}, _resolution) do
    invoice = Invoices.get(id, preload: [{:items, :taxes}, :payments])

    if is_nil(invoice) do
      {:error, message: "Failed!", details: "Invoice not found"}
    else
      Invoices.delete(invoice)
    end
  end

  @spec set_correct_units(Invoices.Invoice.t()) :: Invoices.Invoice.t()
  defp set_correct_units(invoice) do
    Enum.reduce([:net_amount, :gross_amount, :paid_amount], invoice, fn key, invoice ->
      Map.update(invoice, key, 0, fn existing_value ->
        PageView.money_format(existing_value, invoice.currency, symbol: false)
      end)
    end)
  end

  @spec maybe_change_meta_attributes(map, map | nil) :: map
  defp maybe_change_meta_attributes(%{meta_attributes: meta_params} = params, nil) do
    meta_params =
      Enum.reduce(meta_params, %{}, fn map, acc -> Map.put(acc, map.key, map.value) end)

    Map.put(params, :meta_attributes, meta_params)
  end

  defp maybe_change_meta_attributes(
         %{meta_attributes: meta_params} = params,
         invoice_meta_attributes
       ) do
    meta_params =
      Enum.reduce(meta_params, %{}, fn map, acc -> Map.put(acc, map.key, map.value) end)

    all_meta_attributes = Map.merge(invoice_meta_attributes, meta_params)

    Map.put(params, :meta_attributes, all_meta_attributes)
  end

  defp maybe_change_meta_attributes(params, _) do
    params
  end
end

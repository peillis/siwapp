defmodule SiwappWeb.Resolvers.Helpers do
  @moduledoc false

  @spec maybe_change_meta_attributes(map, map | nil) :: map
  def maybe_change_meta_attributes(%{meta_attributes: meta_params} = params, nil) do
    meta_params =
      Enum.reduce(meta_params, %{}, fn map, acc -> Map.put(acc, map.key, map.value) end)

    Map.put(params, :meta_attributes, meta_params)
  end

  def maybe_change_meta_attributes(
        %{meta_attributes: meta_params} = params,
        invoice_meta_attributes
      ) do
    meta_params =
      Enum.reduce(meta_params, %{}, fn map, acc -> Map.put(acc, map.key, map.value) end)

    all_meta_attributes = Map.merge(invoice_meta_attributes, meta_params)

    Map.put(params, :meta_attributes, all_meta_attributes)
  end

  def maybe_change_meta_attributes(params, _) do
    params
  end
end

defmodule SiwappWeb.IframeView do
  use SiwappWeb, :view
  alias Siwapp.Invoices

  def have_items_discount?([]) do
    false
  end

  def have_items_discount?(items) do
    [h | t] = items

    if h.discount != 0 do
      true
    else
      have_items_discount?(t)
    end
  end
end

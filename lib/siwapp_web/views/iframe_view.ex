defmodule SiwappWeb.IframeView do
  use SiwappWeb, :view

  alias SiwappWeb.PageView

  def set_currency(value, currency), do: PageView.set_currency(value, currency)
end

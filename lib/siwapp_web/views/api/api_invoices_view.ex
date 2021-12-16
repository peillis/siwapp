defmodule SiwappWeb.Api.InvoicesView do
  use SiwappWeb, :view

  def render("index.json", %{list: invoices}) do
    %{list: invoices}
  end

end

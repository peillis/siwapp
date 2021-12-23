defmodule SiwappWeb.LayoutView do
  use SiwappWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def new_button(assigns) do
    if assigns.conn.private.phoenix_template == "index.html" do
      "New Invoice"
    else
      live_module = to_string(assigns.live_module)

    cond do
      live_module =~ "Customers" -> "New Customer"
      live_module =~ "Invoices" -> "New Invoice"
      live_module =~ "Series" -> "New Series"
      # explorable in future if more views are needed
      true -> ""
    end
  end
  end
end

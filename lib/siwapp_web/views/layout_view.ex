defmodule SiwappWeb.LayoutView do
  use SiwappWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def new_button(live_module) do
    live_module = to_string(live_module)
    cond do
      live_module =~ "Customers" -> "New Customer"
      live_module =~ "Invoices" -> "New Invoice"
      live_module =~ "Series" -> "New Series"
    end
  end

end

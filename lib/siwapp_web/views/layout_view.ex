defmodule SiwappWeb.LayoutView do
  use SiwappWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def new_button(assigns) do
    path = assigns.conn.request_path

    cond do
      path =~ "taxes" -> "New tax"
      path =~ "customers" -> "New Customer"
      path =~ "series" -> "New Series"
      path =~ "templates" -> "New Template"
      true -> "New Invoice"
    end
  end
end

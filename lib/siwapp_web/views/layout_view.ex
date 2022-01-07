defmodule SiwappWeb.LayoutView do
  use SiwappWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def redirect_path(request_path) do
    case request_path do
      n when n in ["/invoices", "/invoices/edit", "/users/settings", "/"] ->
        :invoices

      n when n in ["/series", "/series/new"] ->
        :series

      n when n in ["/taxes", "/taxes/new"] ->
        :taxes

      n when n in ["/templates", "/templates/new"] ->
        :templates
    end
  end
end

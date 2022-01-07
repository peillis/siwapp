defmodule SiwappWeb.LayoutView do
  use SiwappWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def shared_button(conn) do
    case conn.request_path do
      n when n in ["/invoices", "/invoices/edit", "/users/settings", "/"] ->
        button("New Invoice",
          to: Routes.page_path(conn, :edit_invoices),
          method: :get,
          class: "button is-primary"
        )

      n when n in ["/series", "/series/new"] ->
        button("New Series",
          to: Routes.series_index_path(conn, :new),
          method: :get,
          class: "button is-primary"
        )

      n when n in ["/taxes", "/taxes/new"] ->
        button("New Tax",
          to: Routes.taxes_index_path(conn, :new),
          method: :get,
          class: "button is-primary"
        )

      n when n in ["/templates", "/templates/new"] ->
        button("New Template",
          to: Routes.templates_edit_path(conn, :new),
          method: :get,
          class: "button is-primary"
        )
    end
  end
end

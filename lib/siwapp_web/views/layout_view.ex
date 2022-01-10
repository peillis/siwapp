defmodule SiwappWeb.LayoutView do
  use SiwappWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def shared_button(conn) do
    case conn.request_path do
      n when n in ["/series", "/series/new"] ->
        new_button("New Series", Routes.series_index_path(conn, :new))

      n when n in ["/taxes", "/taxes/new"] ->
        new_button("New Tax", Routes.taxes_index_path(conn, :new))

      n when n in ["/templates", "/templates/new"] ->
        new_button("New Template", Routes.templates_edit_path(conn, :new))

      _ ->
        new_button("New Invoice", Routes.invoices_edit_path(conn, :new))
    end
  end

  defp new_button(text, to) do
    button(text, to: to, method: :get, class: "button is-primary")
  end
end

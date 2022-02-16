defmodule SiwappWeb.IframeController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices
  alias Siwapp.Templates

  plug :put_root_layout, false
  plug :put_layout, false

  def iframe(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series])
    template = Templates.get(:print_default).template
    str_template = Templates.string_template(invoice, template)

    html(conn, str_template)
  end
end

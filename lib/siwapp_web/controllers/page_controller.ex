defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show_invoice(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))

    conn =
      conn
      |> assign(:invoice, invoice)

    render(conn, "show_invoice.html")
  end
end

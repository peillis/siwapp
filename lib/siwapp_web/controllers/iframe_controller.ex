defmodule SiwappWeb.IframeController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices

  plug :put_root_layout, false
  plug :put_layout, false

  def iframe(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), :preload)

    conn =
      conn
      |> assign(:invoice, invoice)

    render(conn, "print_default.html")
  end
end

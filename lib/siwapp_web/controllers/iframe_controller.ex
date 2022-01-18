defmodule SiwappWeb.IframeController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices
  alias Siwapp.Templates

  plug :put_root_layout, false
  plug :put_layout, false

  def iframe(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), :preload)
    template = Templates.get(:print_default).template
    File.write("#{__DIR__}/../templates/iframe/default.html.heex", template)

    conn =
      conn
      |> assign(:invoice, invoice)

    render(conn, "default.html")
  end
end

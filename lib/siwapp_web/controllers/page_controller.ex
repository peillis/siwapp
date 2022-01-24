defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices

  def show_invoice(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))
    conn = assign(conn, :invoice, invoice)
    render(conn, "show_invoice.html")
  end

  def download(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series])
    pdf_file = invoice.series.code <> "-" <> Integer.to_string(invoice.number) <> ".pdf"
    cookie_value = conn.req_cookies["_siwapp_key"]

    cookie = %{
      name: "_siwapp_key",
      value: cookie_value,
      domain: "localhost"
    }

    {:ok, send_conn} =
      ChromicPDF.print_to_pdf({:url, Routes.iframe_url(conn, :iframe, id)},
        set_cookie: cookie,
        output: fn path ->
          send_download(conn, {:file, path}, filename: pdf_file)
        end
      )

    send_conn
  end
end

defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices
  alias Siwapp.Templates

  def show_invoice(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))
    conn = assign(conn, :invoice, invoice)
    render(conn, "show_invoice.html")
  end

  def download(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series])
    str_template = Templates.string_template(invoice)
    name = invoice.series.code <> "-" <> Integer.to_string(invoice.number)
    html_file = name <> ".html"
    pdf_file = name <> ".pdf"
    File.write!(html_file, str_template)

    {:ok, _} =
      ChromicPDF.print_to_pdf({:url, html_file},
        output: fn path ->
          send_download(conn, {:file, path}, filename: pdf_file)
          File.rm!(html_file)
        end
      )
  end
end

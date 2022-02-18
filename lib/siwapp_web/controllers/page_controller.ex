defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices
  alias Siwapp.Templates

  @spec show_invoice(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show_invoice(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))
    conn = assign(conn, :invoice, invoice)
    render(conn, "show_invoice.html")
  end

  @spec download(Plug.Conn.t(), map) :: Plug.Conn.t()
  def download(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series])
    pdf_name = "#{invoice.series.code}-#{Integer.to_string(invoice.number)}.pdf"
    str_template = Templates.string_template(invoice)
    {:ok, data} = ChromicPDF.print_to_pdf({:html, str_template})
    pdf_content = Base.decode64!(data)

    send_download(conn, {:binary, pdf_content}, filename: pdf_name)
  end
end

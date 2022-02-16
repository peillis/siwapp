defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.{Invoices, Templates}

  def show_invoice(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))
    conn = assign(conn, :invoice, invoice)
    render(conn, "show_invoice.html")
  end

  def download(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series])
    pdf_name = "#{invoice.series.code}-#{Integer.to_string(invoice.number)}.pdf"
    template = Templates.get(:print_default).template
    str_template = Templates.string_template(invoice, template)
    {:ok, data} = ChromicPDF.print_to_pdf({:html, str_template})
    pdf_content = Base.decode64!(data)

    send_download(conn, {:binary, pdf_content}, filename: pdf_name)
  end

  def send_email(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), preload: [{:items, :taxes}, :series])

    case Invoices.send_email(invoice) do
      :ok ->
        conn
        |> put_flash(:info, "Email successfully sent")

      :error ->
        conn
        |> put_flash(
          :error,
          "Sending email was impossible. Check invoice data to see if email was provided"
        )
    end
    |> redirect(to: "/")
  end
end

defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller

  alias Siwapp.{Invoices, Templates}

  @spec show_invoice(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show_invoice(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))
    conn = assign(conn, :invoice, invoice)
    render(conn, "show_invoice.html")
  end

  @spec download(Plug.Conn.t(), map) :: Plug.Conn.t()
  def download(conn, %{"id" => id}) do
    invoice = Invoices.get!(id, preload: [{:items, :taxes}, :series])
    {pdf_content, pdf_name} = Templates.pdf_content_and_name(invoice)

    send_download(conn, {:binary, pdf_content}, filename: pdf_name)
  end

  def send_email(conn, %{"id" => id}) do
    Invoices.get!(id, preload: [{:items, :taxes}, :series])
    |> Invoices.send_email()
    |> case do
      {:ok, _id} ->
        conn
        |> put_flash(:info, "Email successfully sent")

      {:error, msg} ->
        conn
        |> put_flash(
          :error,
          msg
        )
    end
    |> redirect(to: "/")
  end
end

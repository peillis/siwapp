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
    invoice = Invoices.get!(id, preload: [{:items, :taxes}, :payments, :series])
    {pdf_content, pdf_name} = Templates.pdf_content_and_name(invoice)

    send_download(conn, {:binary, pdf_content}, filename: pdf_name)
  end

  def download(conn, %{"ids" => ids}) do
    {pdf_content, pdf_name} =
      ids
      |> Enum.map(&Invoices.get!(&1, preload: [{:items, :taxes}, :series]))
      |> Templates.pdf_content_and_name()

    send_download(conn, {:binary, pdf_content}, filename: pdf_name)
  end

  @spec send_email(Plug.Conn.t(), map) :: Plug.Conn.t()
  def send_email(conn, %{"id" => id}) do
    invoice = Invoices.get!(id, preload: [{:items, :taxes}, :payments, :series])

    invoice
    |> Invoices.send_email()
    |> case do
      {:ok, _id} -> put_flash(conn, :info, "Email successfully sent")
      {:error, msg} -> put_flash(conn, :error, msg)
    end
    |> redirect(to: "/")
  end
end

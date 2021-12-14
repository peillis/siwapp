defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def edit_invoices(conn, _params) do
    render(conn, "edit_invoices.html")
  end

  def invoices(conn, _params) do
    render(conn, "invoices.html")
  end

end

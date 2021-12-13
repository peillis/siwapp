defmodule SiwappWeb.InvoicesController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices

  def list(conn, _params) do
    invoices = Invoices.list_invoices()
    json(conn, invoices)
  end

  def searching(conn, params) do
    json(conn, params)
  end

  def show(conn, params) do
    id = Map.get(params, "id")
    json(conn, id)
  end

  def create(conn, invoice) do
    json(conn, invoice)
  end

  def update(conn, updates) do
    json(conn, updates)
  end

  def send_email(conn, params) do
    json(conn, params)
  end

  def delete(conn, params) do
    json(conn, params)
  end
end

defmodule SiwappWeb.InvoicesController do
  use SiwappWeb, :controller
  alias Siwapp.InvoicesContext

  def list(conn, _params) do
    invoices = InvoicesContext.list_invoices()
    json(conn, invoices)
  end

  def searching(conn, %{"map" => map}) do
    {key, value} =
      map
      |> String.split()
      |> List.to_tuple()

    search = InvoicesContext.list_invoices_by(key, value)
    json(conn, search)
  end

  def show(conn, %{"id" => id}) do
    invoice = InvoicesContext.get_invoice!(id)
    json(conn, invoice)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    case InvoicesContext.create_invoice(invoice_params) do
      {:ok, _} -> json(conn, "The invoice was successfully created")
      {:error, changeset} -> json(conn, changeset)
    end
  end

  def update(conn, %{"id" => invoice_params}) do
    case InvoicesContext.update_invoice(conn.assigns.invoice, invoice_params) do
      {:ok, _} -> json(conn, "The invoice was successfully updated")
      {:error, changeset} -> json(conn, changeset)
    end
  end

  def send_email(conn, params) do
    json(conn, params)
  end

  def delete(conn, %{"id" => id}) do
    invoice = InvoicesContext.get_invoice!(id)
    {:ok, response} = InvoicesContext.delete_invoice(invoice)
    json(conn, response)
  end
end

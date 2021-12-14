defmodule SiwappWeb.InvoicesController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices

  def list(conn, _params) do
    invoices = Invoices.list_invoices()
    json(conn, invoices)
  end

  def searching(conn, %{"map" => map}) do
    {key, value} =
      map
      |> String.split()
      |> List.to_tuple()

    search = Invoices.list_invoices_by(key, value)
    json(conn, search)
  end

  def show(conn, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id)
    json(conn, invoice)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    case Invoices.create_invoice(invoice_params) do
      {:ok, _} -> json(conn, "The invoice was successfully created")
      {:error, changeset} -> json(conn, changeset)
    end
  end

  def update(conn, %{"id" => invoice_params}) do
    case Invoices.update_invoice(conn.assigns.invoice, invoice_params) do
      {:ok, _} -> json(conn, "The invoice was successfully updated")
      {:error, changeset} -> json(conn, changeset)
    end
  end

  def send_email(conn, params) do
    json(conn, params)
  end

  def delete(conn, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id)
    {:ok, response} = Invoices.delete_invoice(invoice)
    json(conn, response)
  end
end

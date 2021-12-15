defmodule SiwappWeb.Api.RecurringInvoicesController do
  use SiwappWeb, :controller
  alias Siwapp.RecurringInvoices

  def list(conn, _params) do
    recurring_invoices = RecurringInvoices.list()
    json(conn, recurring_invoices)
  end

  def show(conn, %{"id" => id}) do
    recurring_invoice = RecurringInvoices.get!(id)
    json(conn, recurring_invoice)
  end

  def create(conn, %{"invoice" => recurring_invoice_params}) do
    # case RecurringInvoices.create(recurring_invoice_params) do
    #   {:ok, _} -> json(conn, "The  recurring invoice was successfully created")
    #   {:error, changeset} -> json(conn, changeset)
    # end
  end

  def update(conn, %{"id" => recurring_invoice_params}) do
    case RecurringInvoices.update(conn.assigns.invoice, recurring_invoice_params) do
      {:ok, _} -> json(conn, "The invoice was successfully updated")
      {:error, changeset} -> json(conn, changeset)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    recurring_invoice = RecurringInvoices.get!(id)
    {:ok, response} = RecurringInvoices.delete(recurring_invoice)
    json(conn, response)
  end

  def generate_invoices(conn, %{"id" => id}) do
    generated_invoices = RecurringInvoices.generate_invoices(id)
    json(conn, generated_invoices)
  end
end

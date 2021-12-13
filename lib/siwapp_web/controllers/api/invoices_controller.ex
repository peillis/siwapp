defmodule SiwappWeb.InvoicesController do
  use SiwappWeb, :controller
  # alias AlejandroModuleForRecordings

  def list(conn, _params) do
    # invoices = Recording.list_invoices()
    json(conn, %{data: "invoices"})
  end

  def searching(conn, params) do
    by = Map.get(params, "tuple")
    # invoices_query = Recording.searching_invoices(by)
      json(conn, by)
  end

  def show(conn, params) do
    id = Map.get(params, "id")
    # invoices_show = Recording.show_invoice(id)
    #json(conn, invoices_show)
    json(conn, id)
  end

  def create(conn, invoice) do
    # case Invoice.register_invioce(invoice) do
    #   {:ok, invoice} ->
    #     {:ok, _} =
    #     conn
    #     |> put_flash(:info, "The invoice has been added successfully.")
    #     |> redirect(to: "/")

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "index.html", changeset: changeset)
    # end
    json(conn, invoice)
  end

  def update(conn, updates) do
    # case Invoice.edit_invoice(conn.assigns.invoice.id, updates) do
    #   {:ok, _} ->
    #     conn
    #     |> put_flash(:info, "the invoice has been edit successfully.")
    #     |> redirect(to: "/")

    #   {:error, changeset} ->
    #     render(conn, "edit.html", changeset: changeset)
    # end
    json(conn, updates)
  end

  def send_email(conn, params) do
    # conn
    # |> put_flash(:info, "E-mail succesfully sent.")
    # |> Invoice.send_email()
    json(conn, params)
  end

  def delete(conn, params) do
    # conn
    # |> put_flash(:info, "Logged out successfully.")
    # |> Invoice.delete_invoice()
    json(conn, params)
  end

end

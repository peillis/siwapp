defmodule SiwappWeb.Api.InvoicesController do
  use SiwappWeb, :controller

  import Ecto.Changeset

  alias JSONAPI.{Serializer, Utils}
  alias Siwapp.Invoices
  alias SiwappWeb.Api.InvoicesView

  def index(conn, _params) do
    invoices = Invoices.list_preload(preload: [:items])
    json = Serializer.serialize(InvoicesView, invoices, conn)
    render(conn, list: json)
  end

  def show(conn, %{"id" => id}) do
    invoice = Invoices.get!(id, preload: [{:items, :taxes}, :series])
    json = Serializer.serialize(InvoicesView, invoice, conn)
    render(conn, show: json)
  end

  def create(conn, params) do
    params = Utils.String.expand_fields(params, &Utils.String.underscore/1)

    case Invoices.create(params) do
      {:ok, invoice} ->
        invoice = Invoices.get!(invoice.id, preload: [{:items, :taxes}, :series])
        json = Serializer.serialize(InvoicesView, invoice, conn)

        conn
        |> Plug.Conn.put_status(201)
        |> render(create: json)

      {:error, changeset} ->
        errors = traverse_errors(changeset, fn {msg, _opt} -> msg end)

        conn
        |> Plug.Conn.put_status(409)
        |> render(create: %{"errors" => errors})
    end
  end

  def update(conn, %{"id" => id} = invoice_params) do
    invoice = Invoices.get(id, preload: [{:items, :taxes}, :series])

    if invoice == nil do
      conn
      |> Plug.Conn.put_status(404)
      |> render(update: %{"errors" => "Invoice not found"})
    else
      case Invoices.update(invoice, invoice_params) do
        {:ok, invoice} ->
          invoice = Invoices.get(invoice.id, preload: [{:items, :taxes}, :series])
          json = Serializer.serialize(InvoicesView, invoice, conn)
          render(conn, update: json)

        {:error, changeset} ->
          errors = traverse_errors(changeset, fn {msg, _opt} -> msg end)

          conn
          |> Plug.Conn.put_status(409)
          |> render(update: %{"errors" => errors})
      end
    end
  end

  def send_email(conn, params) do
    json(conn, params)
  end

  def delete(conn, %{"id" => id}) do
    invoice = Invoices.get(id)

    if invoice == nil do
      conn
      |> Plug.Conn.put_status(404)
      |> render(error: :not_found)
    else
      {:ok, _response} = Invoices.delete(invoice)
      render(conn, delete: id)
    end
  end

  def download(conn, params) do
    SiwappWeb.PageController.download(conn, params)
  end
end

defmodule SiwappWeb.Api.InvoicesController do
  use SiwappWeb, :controller

  import Ecto.Changeset

  alias JSONAPI.{Serializer, Utils}
  alias Siwapp.Invoices
  alias SiwappWeb.Api.InvoicesView

  def index(conn, _params) do
    invoices = Invoices.list(:preload)
    json = Serializer.serialize(InvoicesView, invoices, conn)
    render(conn, list: json)
  end

  def searching(conn, %{"map" => map}) do
    {key, value} =
      map
      |> String.split()
      |> List.to_tuple()

    search = Invoices.list_by(key, value)
    json(conn, search)
  end

  def show(conn, %{"id" => id}) do
    invoice = Invoices.get!(id, preload: [:customer, {:items, :taxes}, :series])
    json = Serializer.serialize(InvoicesView, invoice, conn)
    render(conn, show: json)
  end

  def create(conn, params) do
    params = Utils.String.expand_fields(params, &Utils.String.underscore/1)

    case Invoices.create(params) do
      {:ok, invoice} ->
        invoice = Invoices.get!(invoice.id, preload: [:customer, {:items, :taxes}, :series])
        json = Serializer.serialize(InvoicesView, invoice, conn)
        render(conn, create: json)

      {:error, changeset} ->
        changeset = traverse_errors(changeset, fn {msg, _opt} -> msg end)
        render(conn, create: %{"errors" => changeset})
    end
  end

  def update(conn, %{"id" => invoice_params}) do
    case Invoices.update(conn.assigns.invoice, invoice_params) do
      {:ok, _} -> json(conn, "The invoice was successfully updated")
      {:error, changeset} -> json(conn, changeset)
    end
  end

  def send_email(conn, params) do
    json(conn, params)
  end

  def delete(conn, %{"id" => id}) do
    invoice = Invoices.get!(id)
    {:ok, response} = Invoices.delete(invoice)
    json(conn, response)
  end
end

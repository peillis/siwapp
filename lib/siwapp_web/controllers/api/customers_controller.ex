defmodule SiwappWeb.Api.CustomersController do
  use SiwappWeb, :controller

  import Ecto.Changeset

  alias JSONAPI.{Serializer, Utils}
  alias Siwapp.Customers
  alias SiwappWeb.Api.CustomersView

  def create(conn, params) do
    params = Utils.String.expand_fields(params, &Utils.String.underscore/1)

    case Customers.create(params) do
      {:ok, customer} ->
        customer = Customers.get!(customer.id, :preload)
        json = Serializer.serialize(CustomersView, customer, conn)

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

  def update(conn, customers_params = %{"id" => id}) do
    customer = Customers.get_by_id(id)

    if customer == nil do
      conn
      |> Plug.Conn.put_status(404)
      |> render(update: %{"errors" => "Customer not found"})
    else
      case Customers.update(customer, customers_params) do
        {:ok, customer} ->
          customer = Customers.get!(customer.id, :preload)
          json = Serializer.serialize(CustomersView, customer, conn)
          render(conn, update: json)

        {:error, changeset} ->
          errors = traverse_errors(changeset, fn {msg, _opt} -> msg end)

          conn
          |> Plug.Conn.put_status(409)
          |> render(update: %{"errors" => errors})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    customer = Customers.get_by_id(id, :preload)

    if customer == nil do
      conn
      |> Plug.Conn.put_status(404)
      |> render(not_found: id)
    else
      case Customers.delete(customer) do
        {:ok, _response} ->
          render(conn, delete: id)

        {:error, _response} ->
          conn
          |> Plug.Conn.put_status(202)
          |> render(error: id)
      end
    end
  end
end

defmodule SiwappWeb.Api.CustomersControllerTest do
  use SiwappWeb.ConnCase, async: true

  alias Siwapp.ApiToken
  alias Siwapp.Customers

  import Siwapp.CustomersFixtures
  import Siwapp.AccountsFixtures
  import Plug.Conn

  setup %{conn: conn} do
    user = user_fixture()
    token = ApiToken.sign(%{user_id: user.id})
    conn = put_req_header(conn, "authorization", "Bearer " <> token)
    %{conn: conn}
  end

  describe "read API operations for customers" do
    test "send response 200 if it finds a customer", %{conn: conn} do
      customer = customer_fixture()
      conn = get(conn, Routes.customers_path(conn, :show, customer.id))
      assert json_response(conn, 200)
    end

    test "send response 404 if the customer is 'Not found'", %{conn: conn} do
      conn = get(conn, Routes.customers_path(conn, :show, 0))
      assert json_response(conn, 404)
    end
  end

  describe "create API operations for customers" do
    setup do
      customer_params = valid_customer_attributes()
      %{customer_params: customer_params}
    end

    test "send 201 response after a customer creation and do a query of customer after being created",
         %{
           conn: conn,
           customer_params: customer_params
         } do
      conn = post(conn, Routes.customers_path(conn, :create, customer_params))
      id = conn.assigns.create.data.attributes["id"]
      assert json_response(conn, 201)
      assert Customers.get(id) !== nil
    end

    test "send 409 response if the customer can't be created", %{conn: conn} do
      conn = post(conn, Routes.customers_path(conn, :create))
      assert json_response(conn, 409)
    end
  end

  describe "update API operations for customer" do
    test "send 200 response if the customer has been suscesfully updated", %{conn: conn} do
      customer = customer_fixture()

      conn =
        put(
          conn,
          Routes.customers_path(conn, :update, customer.id, %{email: unique_customer_email()})
        )

      assert json_response(conn, 200)
    end

    test "send 409 response if the customer can't be updated", %{conn: conn} do
      customer = customer_fixture()

      conn =
        put(
          conn,
          Routes.customers_path(conn, :update, customer.id, %{email: "invalid_email.com"})
        )

      assert json_response(conn, 409)
    end

    test "send 404 response if the customer is Not found", %{conn: conn} do
      conn = put(conn, Routes.customers_path(conn, :update, 0, %{email: unique_customer_email()}))
      assert json_response(conn, 404)
    end
  end

  describe "delete API operations for customer" do
    test "send 204 response if the customer has been suscesfully deleted", %{conn: conn} do
      customer = customer_fixture()
      conn = delete(conn, Routes.customers_path(conn, :delete, customer.id))
      assert json_response(conn, 200)
    end

    test "send 404 response if the customer id is Not found", %{conn: conn} do
      conn = delete(conn, Routes.customers_path(conn, :delete, 0))
      assert json_response(conn, 404)
    end
  end
end

defmodule SiwappWeb.SchemaTest do
  use SiwappWeb.ConnCase, async: true

  import Siwapp.InvoicesFixtures
  import Siwapp.CustomersFixtures

  setup do
    invoice_fixture(%{name: "test1"})
    invoice_fixture(%{name: "test2"})
  end

  describe "invoices" do
    test "list invoices", %{conn: conn} do
      query = """
        query {
          invoices {
            name
          }
        }
      """

      conn
      |> post("/graphql/graphiql", %{query: query})
      |> json_response(200)

      assert %{"data" => %{"invoices" => [%{"name" => "test1"}, %{"name" => "test2"}]}}
    end
  end
end

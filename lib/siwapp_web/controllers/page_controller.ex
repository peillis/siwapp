defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Repo
  alias Siwapp.Searches
  alias Siwapp.Templates

  @type type_of_struct ::
          Siwapp.Invoices.Invoice.t()
          | Siwapp.Customers.Customer.t()
          | Siwapp.RecurringInvoices.RecurringInvoice.t()

  @spec show_invoice(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show_invoice(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id))
    conn = assign(conn, :invoice, invoice)
    render(conn, "show_invoice.html")
  end

  @spec download(Plug.Conn.t(), map) :: Plug.Conn.t()
  def download(conn, %{"id" => id}) do
    invoice = Invoices.get!(id, preload: [{:items, :taxes}, :payments, :series])
    {pdf_content, pdf_name} = Templates.pdf_content_and_name(invoice)

    send_download(conn, {:binary, pdf_content}, filename: pdf_name)
  end

  @spec send_email(Plug.Conn.t(), map) :: Plug.Conn.t()
  def send_email(conn, %{"id" => id}) do
    invoice = Invoices.get!(id, preload: [{:items, :taxes}, :payments, :series])

    invoice
    |> Invoices.send_email()
    |> case do
      {:ok, _id} -> put_flash(conn, :info, "Email successfully sent")
      {:error, msg} -> put_flash(conn, :error, msg)
    end
    |> redirect(to: "/")
  end

  @spec csv(Plug.Conn.t(), map) :: Plug.Conn.t()
  def csv(conn, params) do
    {queryable, fields} = which_queryable_and_fields(params["view"])

    query_params =
      params
      |> Map.delete("view")
      |> Enum.reject(fn {_key, val} -> val == "" end)

    conn =
      conn
      |> put_resp_content_type("application/csv")
      |> put_resp_header("content-disposition", "attachment; filename=#{params["view"]}s.csv")
      |> send_chunked(200)

    queryable
    |> get_values_from_a_queryable(query_params, fields)
    |> CSV.encode()
    |> Enum.reduce_while(conn, fn (chunk, conn) ->
      case chunk(conn, chunk) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end

  @spec which_queryable_and_fields(binary) :: Ecto.Queryable.t()
  defp which_queryable_and_fields(view) do
    case view do
      "invoice" ->
        {Invoice, Invoice.fields()}

      "customer" ->
        {Customer, Customer.fields()}

      "recurring_invoice" ->
        {RecurringInvoice, RecurringInvoice.fields()}
    end
  end

  # Get a stream of the values for each key from every invoice, recurring_invoice or customer a user decide to filter
  #@spec get_values_from_a_queryable(type_of_struct(), [{binary, binary}], list()) :: Enumerable.t()
  defp get_values_from_a_queryable(queryable, query_params, fields) do
    values=
      queryable
      |> Searches.filters_query(query_params)
      |> Repo.all()
      |> Enum.map(&prepare_values(&1,fields))

    keys_plus_values = [fields] ++ values

    Stream.map(keys_plus_values, & &1)
  end

  @spec prepare_values(type_of_struct(), [atom]) :: list()
  defp prepare_values(struct, fields) do
    struct
    |> Map.from_struct()
    |> sort_values(fields)
  end

  @spec sort_values(map, list) :: list
  defp sort_values(map, fields) do
    Enum.reduce(fields, [], fn key, acc -> acc ++ [Map.get(map, key)] end)
  end
end

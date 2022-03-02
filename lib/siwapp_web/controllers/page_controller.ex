defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices
  alias Siwapp.Invoices.Invoice
  alias Siwapp.RecurringInvoices.RecurringInvoice
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

  def download(conn, %{"ids" => ids}) do
    {pdf_content, pdf_name} =
      ids
      |> Enum.map(&Invoices.get!(&1, preload: [{:items, :taxes}, :payments, :series]))
      |> Templates.pdf_content_and_name()

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

    values_list = get_values_from_a_queryable(queryable, query_params, fields)
    keys_plus_values = [fields] ++ values_list

    csv_content =
      keys_plus_values
      |> CSV.encode()
      |> Enum.take(length(values_list) + 1)
      |> Enum.reduce("", fn val, acc -> acc <> val end)

    send_download(conn, {:binary, csv_content}, filename: "#{params["view"]}s.csv")
  end

  # Get the values for each key from every invoice, recurring_invoice or customer a user decide to filter
  @spec get_values_from_a_queryable(Ecto.Queryable.t(), [{binary, binary}], [atom]) ::
          [list()] | []
  defp get_values_from_a_queryable(queryable, query_params, fields) do
    queryable
    |> Searches.filters(query_params)
    |> Enum.map(&prepare_values(&1, fields))
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

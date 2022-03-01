defmodule SiwappWeb.PageController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices
  alias Siwapp.Searches
  alias Siwapp.Templates

  @reject_fields [
    :series,
    :customer,
    :recurring_invoice,
    :items,
    :__meta__,
    :taxes_amounts,
    :meta_attributes,
    :payments,
    :recurring_invoices,
    :invoices
  ]

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
    queryable = which_queryable(params["view"])

    query_params =
      params
      |> Map.delete("view")
      |> Enum.reject(fn {_key, val} -> val == "" end)

    keys_list = get_keys_from_a_queryable(queryable)
    values_list = get_values_from_a_queryable(queryable, query_params)

    keys_plus_values = [keys_list] ++ values_list

    csv_content =
      keys_plus_values
      |> CSV.encode()
      |> Enum.take(length(values_list) + 1)
      |> Enum.reduce("", fn val, acc -> acc <> val end)

    send_download(conn, {:binary, csv_content}, filename: "#{params["view"]}s.csv")
  end

  @spec get_values_from_a_queryable(Ecto.Queryable.t(), [{binary, binary}]) :: list(list()) | []
  def get_values_from_a_queryable(queryable, query_params) do
    queryable
    |> Searches.filters(query_params)
    |> Enum.map(&prepare_values(&1))
  end

  @spec get_keys_from_a_queryable(Ecto.Queryable.t()) :: list()
  def get_keys_from_a_queryable(queryable) do
    queryable
    |> struct()
    |> Map.from_struct()
    |> Enum.reject(fn {key, _val} -> key in @reject_fields end)
    |> Enum.sort()
    |> Keyword.keys()
  end

  @spec which_queryable(binary) :: Ecto.Queryable.t()
  defp which_queryable(view) do
    case view do
      "invoice" ->
        Siwapp.Invoices.Invoice

      "customer" ->
        Siwapp.Customers.Customer

      "recurring_invoice" ->
        Siwapp.RecurringInvoices.RecurringInvoice
    end
  end

  @spec prepare_values(type_of_struct()) :: list()
  defp prepare_values(struct) do
    struct
    |> Map.from_struct()
    |> Enum.reject(fn {key, _val} -> key in @reject_fields end)
    |> Enum.sort()
    |> Keyword.values()
  end
end

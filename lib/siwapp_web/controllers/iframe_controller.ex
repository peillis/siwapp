defmodule SiwappWeb.IframeController do
  use SiwappWeb, :controller
  alias Siwapp.Invoices
  alias Siwapp.Templates

  plug :put_root_layout, false
  plug :put_layout, false

  def iframe(conn, %{"id" => id}) do
    invoice = Invoices.get!(String.to_integer(id), :preload)
    template = Templates.get(:print_default).template

    invoice_eval_data =
      invoice
      |> Map.from_struct()
      |> Enum.map(fn {key, value} -> {key, value} end)

    all_eval_data =
      invoice_eval_data ++
        [have_discount?: have_items_discount?(invoice.items), status: Invoices.status(invoice)]

    str_template = EEx.eval_string(template, all_eval_data)
    html(conn, str_template)
  end

  defp have_items_discount?([]) do
    false
  end

  defp have_items_discount?(items) do
    [h | t] = items

    if h.discount != 0 do
      true
    else
      have_items_discount?(t)
    end
  end
end
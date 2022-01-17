defmodule SiwappWeb.InvoicesLive.Show do
  use SiwappWeb, :live_view
  alias Siwapp.Invoices

  def mount(%{"id" => id}, _session, socket) do
    invoice = Invoices.get!(String.to_integer(id))

    {:ok,
     socket
     |> assign(:invoice, invoice)}
  end
end

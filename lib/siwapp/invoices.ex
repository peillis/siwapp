defmodule Siwapp.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo

  alias Siwapp.Schema.Invoices

  @doc """
  Gets a list of invoices by updated date.
  """
  def list_invoices() do
    Repo.all(
      from(
        i in Invoices,
        order_by: [desc: i.updated_at]
      )
    )
  end

  @doc """
  Creates an invoice.
  """
  def create_invoice(attrs \\ %{}) do
    %Invoices{}
    |> Invoices.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an invoice.
  """
  def update_invoice(%Invoices{} = invoice, attrs) do
    invoice
    |> Invoices.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an invoice.
  """
  def delete_invoice(%Invoices{} = invoice) do
    Repo.delete(invoice)
  end
end

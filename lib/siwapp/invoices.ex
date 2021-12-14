defmodule Siwapp.Invoice do
  @moduledoc """
  The Invoice context.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo

  alias Siwapp.Schema.Invoice

  @doc """
  Gets a list of Invoice by updated date.
  """
  def list_Invoice() do
    Repo.all(
      from(
        i in Invoice,
        order_by: [desc: i.updated_at]
      )
    )
  end

  @doc """
  Creates an invoice.
  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an invoice.
  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an invoice.
  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end
end

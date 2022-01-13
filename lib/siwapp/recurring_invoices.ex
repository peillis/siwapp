defmodule Siwapp.RecurringInvoices do
  @moduledoc """
  Recurring Invoices context.
  """
  import Ecto.Query, warn: false

  alias Siwapp.RecurringInvoices.RecurringInvoice
  alias Siwapp.Repo

  def list do
    # query = Query.invoices()
    Repo.all(RecurringInvoice)
  end

  def get!(id), do: Repo.get!(RecurringInvoice, id)

  def get!(id, :preload),
  do: Repo.get!(RecurringInvoice, id) |> Repo.preload([:customer, {:invoices, :items}, :series])

  def create(attrs \\ %{}) do
    %RecurringInvoice{}
    |> RecurringInvoice.changeset(attrs)
    |> Repo.insert()
  end

  def update(recurring_invoice, attrs) do
    recurring_invoice
    |> RecurringInvoice.changeset(attrs)
    |> Repo.update()
  end

  def delete(recurring_invoice) do
    Repo.delete(recurring_invoice)
  end

  def generate_invoices(id) do
    Repo.get!(RecurringInvoice, id)
  end

  def change(%RecurringInvoice{} = recurring_invoice, attrs \\ %{}) do
    RecurringInvoice.changeset(recurring_invoice, attrs)
  end
end

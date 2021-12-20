defmodule Siwapp.RecurringInvoices do
  import Ecto.Query, warn: false

  alias Siwapp.Repo
  alias Siwapp.RecurringInvoices.RecurringInvoice

  def list() do
    # query = Query.invoices()
    Repo.all(RecurringInvoice)
  end

  def get!(id), do: Repo.get!(RecurringInvoice, id)

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

defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """
  import Ecto.Query

  alias Siwapp.Customers.Customer
  alias Siwapp.Invoices.{Invoice, InvoiceQuery}
  alias Siwapp.Query
  alias Siwapp.Repo

  @doc """
  Lists customers in database
  """
  def list(limit \\ 100, offset \\ 0) do
    Customer
    |> order_by(desc: :id)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  def suggest_by_name_input(""), do: []
  def suggest_by_name_input(nil), do: []

  def suggest_by_name_input(name_input) do
    Customer
    |> Query.search_in_string(:name, "%#{name_input}%")
    |> Repo.all()
  end

  @doc """
  Create a new customer
  """
  def create(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update a customer
  """
  def update(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a customer
  """
  def delete(%Customer{} = customer) do
    Repo.delete(customer)
  rescue
    e in Ecto.ConstraintError -> {:error, e.message}
  end

  @doc """
  Gets a customer by id
  """
  def get!(id), do: Repo.get!(Customer, id)
  def get!(id, :preload), do: Repo.get!(Customer, id) |> Repo.preload([:invoices])

  @doc """
  Gets a customer by id
  """
  def get(id), do: Repo.get(Customer, id)

  @spec get(binary | nil, binary | nil) :: Customer.t() | nil
  def get(nil, nil), do: nil
  def get(nil, name), do: get_by_hash_id("", name)
  def get(identification, nil), do: get(identification, "")

  def get(identification, name) do
    case Repo.get_by(Customer, identification: identification) do
      nil -> get_by_hash_id(identification, name)
      customer -> customer
    end
  end

  def exists_with_name?(nil), do: nil

  def exists_with_name?(name) do
    Customer
    |> Query.by(:name, name)
    |> Repo.exists?()
  end

  def change(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  def money(customer_id, type) do
    currency =
      case currencies(customer_id) do
        [nil] -> nil
        [currency] -> String.to_existing_atom(currency)
        _ -> nil
      end

    {amount(customer_id, type), currency}
  end

  defp currencies(customer_id) do
    Invoice
    |> InvoiceQuery.currencies_for_customer(customer_id)
    |> Repo.all()
  end

  def amount(customer_id, :due) do
    case {amount(customer_id, :total), amount(customer_id, :paid)} do
      {total, nil} -> total || 0
      {nil, paid} -> -paid
      {total, paid} -> total - paid
    end
  end

  def amount(customer_id, type) do
    Invoice
    |> InvoiceQuery.amount_for_customer(customer_id, type)
    |> Repo.one() || 0
  end

  @spec get_by_hash_id(binary, binary) :: Customer.t() | nil
  defp get_by_hash_id(identification, name) do
    hash_id = Customer.create_hash_id(identification, name)

    case Repo.get_by(Customer, hash_id: hash_id) do
      nil -> nil
      customer -> customer
    end
  end
end

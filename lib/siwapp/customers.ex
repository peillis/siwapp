defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """
  import Ecto.Query

  alias Siwapp.Customers.Customer
  alias Siwapp.Query
  alias Siwapp.Repo

  @doc """
  Lists customers in database preloading invoices whose draft and failed fields are false
  """
  def list(limit \\ 100, offset \\ 0) do
    Customer
    |> order_by(desc: :id)
    |> limit(^limit)
    |> offset(^offset)
    |> custom_preload()
    |> Repo.all()
  end

  @doc """
  List of customers in database assigning virtual fields of
  total, paid, due and currency taking advantage of having
  preloaded invoices before
  """
  def list_index(limit, offset) do
    list(limit, offset)
    |> Enum.map(&%{&1 | total: total(&1.invoices)})
    |> Enum.map(&%{&1 | paid: paid(&1.invoices)})
    |> Enum.map(&%{&1 | due: &1.total - &1.paid})
    |> Enum.map(&%{&1 | currency: currency(&1.invoices)})
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

  # Custom query to preload only invoices that aren't draft nor failed
  defp custom_preload(query) do
    from(c in query,
      join: i in assoc(c, :invoices),
      where: i.draft == false and i.failed == false,
      preload: [invoices: i]
    )
  end

  # Returns the sum, regarding all invoices associated to a customer, of
  # corresponding total (original amount to pay) and paid (amount already paid).
  # It doesn't take into account currencies.
  defp total(invoices) do
    invoices
    |> Enum.map(& &1.gross_amount)
    |> Enum.sum()
  end

  defp paid(invoices) do
    invoices
    |> Enum.map(& &1.paid_amount)
    |> Enum.sum()
  end

  # Returns the currency associated to a customer invoices' if there's
  # only one, otherwise, returns nil (assuming currency in saved invoice
  # is never nil)
  defp currency(invoices) do
    invoices
    |> Enum.map(& &1.currency)
    |> Enum.uniq()
    |> case do
      [currency] -> String.to_atom(currency)
      _ -> nil
    end
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

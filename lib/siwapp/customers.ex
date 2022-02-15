defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """

  alias Siwapp.Customers.{Customer, CustomerQuery}
  alias Siwapp.Query
  alias Siwapp.Repo

  @doc """
  Lists customers in database
  """
  def list(limit \\ 100, offset \\ 0), do: CustomerQuery.list(limit, offset) |> Repo.all()

  @doc """
  Lists customers in database only providing necessary fields to render index, including
  virtuals
  """
  def list_index(limit \\ 100, offset \\ 0) do
    CustomerQuery.list_for_index(limit, offset)
    |> Repo.all()
    |> Enum.map(&%{&1 | currency: final_currency(&1.currency), due: &1.total - &1.paid})
  end

  def suggest_by_name(""), do: []
  def suggest_by_name(nil), do: []

  def suggest_by_name(name) do
    Customer
    |> Query.search_in_string(:name, "%#{name}%")
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

  def change(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  # Returns currency converted to atom only if
  # input was a list containing just one currency
  @spec final_currency([] | [String.t()]) :: atom
  defp final_currency([]), do: nil
  defp final_currency([currency]), do: String.to_atom(currency)
  defp final_currency(_list), do: nil

  @spec get_by_hash_id(binary, binary) :: Customer.t() | nil
  defp get_by_hash_id(identification, name) do
    hash_id = Customer.create_hash_id(identification, name)

    case Repo.get_by(Customer, hash_id: hash_id) do
      nil -> nil
      customer -> customer
    end
  end
end

defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """
  alias Siwapp.Customers.Customer
  alias Siwapp.Query
  alias Siwapp.Repo

  @doc """
  Lists customers in database
  """
  def list, do: Repo.all(Customer)

  def scroll_listing(page, per_page \\ 20) do
    Customer
    |> Query.paginate(page, per_page)
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

  @spec get_by_hash_id(binary, binary) :: Customer.t() | nil
  defp get_by_hash_id(identification, name) do
    hash_id = Customer.create_hash_id(identification, name)

    case Repo.get_by(Customer, hash_id: hash_id) do
      nil -> nil
      customer -> customer
    end
  end
end

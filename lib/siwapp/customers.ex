defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """
  alias Siwapp.Repo
  alias Siwapp.Customers.Customer

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
  end

  @doc """
  Gets a customer by id
  """
  def get!(id), do: Repo.get!(Customer, id)

  def get_by(:name, name) do
    hash_id = create_hash_id(name)
    get_by(:hash_id, hash_id)
  end

  def get_by(field, value),
    do: Repo.get_by!(Customer, [{field, value}])

  def change(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  def identification_exist?(identification) do
    Customer.query_by(:identification, identification)
    |> Repo.exists?()
  end

  def name_exist?(name) do
    hash_id = create_hash_id(name)

    Customer.query_by(:hash_id, hash_id)
    |> Repo.exists?()
  end

  defp create_hash_id(name) do
    %Customer{name: name}
    |> Ecto.Changeset.change(%{})
    |> Customer.create_hash_id()
    |> Ecto.Changeset.get_change(:hash_id)
  end
end

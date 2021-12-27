defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """
  alias Siwapp.Repo
  alias Siwapp.Customers.Customer
  alias Siwapp.Customers.Query

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
    hash_id = create_hash_id_when_iden_is_nil(name)
    get_by(:hash_id, hash_id)
  end
  def get_by(field, value),
    do: Repo.get_by!(Customer, [{field, value}])


  def change(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  def exist_identification?(identification) do
    Query.by(:identification, identification)
    |> Repo.exists?()
  end

  def exist_name_when_iden_is_nil?(name) do
    hash_id = create_hash_id_when_iden_is_nil(name)

    Query.by(:hash_id, hash_id)
    |> Repo.exists?()
  end

  defp create_hash_id_when_iden_is_nil(name) do
    name =
      name
      |> String.downcase()
      |> String.replace(~r/ +/, "")

    :crypto.hash(:md5, name)
    |> Base.encode16()
  end
end

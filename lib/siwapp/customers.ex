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

  def change(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end
end

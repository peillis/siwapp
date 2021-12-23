defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """
  import Ecto.Query, warn: false
  alias Siwapp.Repo
  alias Siwapp.Customers.Customer

  def list(), do: Repo.all(Customer)

  def new(), do: %Customer{}

  def change(customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
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
  end

  @doc """
  Gets a customer by id
  """
  def get!(id) do
    Repo.get!(Customer, id)
    |> Repo.preload(:invoices)
  end
end

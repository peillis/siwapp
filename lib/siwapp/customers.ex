defmodule Siwapp.Customers do
  @moduledoc """
  The Customers context.
  """
  alias Siwapp.Repo
  alias Siwapp.Customers.Customer
  alias Siwapp.MetaAttributes.MetaAttribute

  import Ecto.Query

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
    |> Repo.preload([ meta_attribute: from( m in MetaAttribute, order_by: m.id )] )
  end

  def change(%Customer{} = customer ) do
    Customer.changeset(customer, %{} )
  end
end

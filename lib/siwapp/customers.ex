defmodule Siwapp.Customer do
  @moduledoc """
  The Customer context.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo

  alias Siwapp.Schema.Customer


  @doc """
  Creates a customer.
  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.
  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.
  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end
end

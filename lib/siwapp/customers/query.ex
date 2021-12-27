defmodule Siwapp.Customers.Query do
  import Ecto.Query

  alias Siwapp.Customers.Customer

  def by(field, value) do
    where(Customer, ^[{field, value}])
  end
end

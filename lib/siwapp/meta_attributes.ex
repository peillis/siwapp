defmodule Siwapp.MetaAttributes do

  import Ecto.Query

  alias Siwapp.Repo
  alias Siwapp.Customers.Customer
  alias Siwapp.MetaAttributes.MetaAttribute

  def list(customer ) do
    from( m in MetaAttribute, where: [customer_id: ^customer.id], order_by: [asc: :id] )
    |> Repo.all()
  end

  def get!(customer, id), do: Repo.get_by!(MetaAttribute, customer_id: customer.id, id: id)

  def create(customer, attrs \\ %{}) do
    customer
    |> Ecto.build_embedded(:meta_attributes)
    |> MetaAttribute.changeset(attrs)
    |> Repo.insert()
  end

  def update(%MetaAttribute{} = meta_attribute, attrs) do
    meta_attribute
    |> MetaAttribute.changeset(attrs)
    |> Repo.update()
  end

  def change(%MetaAttribute{} = meta_attribute) do
    MetaAttribute.changeset( meta_attribute, %{} )
  end

end



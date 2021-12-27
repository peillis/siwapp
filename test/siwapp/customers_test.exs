defmodule Siwapp.CustomersTest do
  use Siwapp.DataCase

  import Siwapp.CustomersFixtures
  alias Siwapp.Customers

  describe "create_customer/1" do
    test "requires name or identification to be set" do
      {:error, changeset} = Customers.create(%{})

      assert %{
               name: ["Either name or identification are required"]
             } = errors_on(changeset)
    end

    test "validates identification uniqueness" do
      %{name: name, identification: identification} = customer_fixture()
      {:error, changeset} = Customers.create(%{name: name, identification: identification})
      assert "has already been taken" in errors_on(changeset).identification

      # Now try with the upper cased email too, to check that name case is ignored.
      {:error, changeset} =
        Customers.create(%{name: String.upcase(name), identification: identification})

      assert "has already been taken" in errors_on(changeset).identification
    end

    test "validates hash_id uniqueness" do
      %{name: name, identification: identification} = customer_fixture(%{identification: nil})
      {:error, changeset} = Customers.create(%{name: name, identification: identification})
      assert "has already been taken" in errors_on(changeset).hash_id

      # Now try with the upper cased email too, to check that name case is ignored.
      {:error, changeset} =
        Customers.create(%{name: String.upcase(name), identification: identification})

      assert "has already been taken" in errors_on(changeset).hash_id
    end
  end
end

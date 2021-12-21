alias Siwapp.Customers
alias Siwapp.Invoices

defmodule Script do
  def create(name, amount, date) do
    {:ok, c} = Customers.create(%{name: name})
    Invoices.create(%{name: name, customer_id: c.id, gross_amount: amount, issue_date: date})
  end
end

Script.create("Pepe", 10_500, ~D[2021-11-10])
Script.create("Alonso", 12_600, ~D[2021-11-15])
Script.create("Maria", 12_000, ~D[2021-11-15])
Script.create("Ana", 3_700, ~D[2021-11-21])
Script.create("Jose", 7_700, ~D[2021-11-22])
Script.create("Jesus", 9_900, ~D[2021-11-30])
Script.create("Cao", 23_200, ~D[2021-12-01])
Script.create("Lola", 22_100, ~D[2021-12-02])
Script.create("Lolita", 1_500, ~D[2021-12-03])
Script.create("Sergio", 2_500, ~D[2021-12-03])
Script.create("Alvaro", 10_000, ~D[2021-12-03])
Script.create("Rocio", 12_100, ~D[2021-12-04])
Script.create("Panlo", 3_200, ~D[2021-12-04])
Script.create("Juan", 4_500, ~D[2021-12-20])

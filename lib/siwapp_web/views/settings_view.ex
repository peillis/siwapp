defmodule SiwappWeb.SettingsView do
  use SiwappWeb, :view

  #Yo creo que es mejor definir tipos personalizados para poder hacer el cast usando Ecto al usarlos
  def adequate_input(label, type, f) do
    cond do
      to_string(label) =~ "email" -> email_input f, label
      to_string(label) =~ "phone" -> telephone_input f, label
      to_string(label) =~ "currency" -> select f, label, ["USD", "EUR"]  #Provisional
      to_string(label) =~ "address" || to_string(label) =~ "terms" -> textarea f, label 
      type == :integer -> number_input f, label
      type == :string ->  text_input f, label
    end
  end
end

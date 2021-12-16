defmodule SiwappWeb.CustomerLive.FormComponent do
  use SiwappWeb, :live_component

  def render(assigns) do
    SiwappWeb.CustomerView.render("customer_form.html", assigns)
  end
end

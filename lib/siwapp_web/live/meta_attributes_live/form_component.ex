defmodule SiwappWeb.MetaAttributesLive.FormComponent do
  use SiwappWeb, :live_component

  def render(assigns) do
    SiwappWeb.MetaAttributesView.render("meta_attributes_form.html", assigns)
  end
end

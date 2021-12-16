<<<<<<< HEAD
defmodule SiwappWeb.MetaAttributesLive do
=======
defmodule SiwappWeb.MetaAttributesLive do 
>>>>>>> 676d2b263ea6d40f8f28e18cc41c38e5bc47f7df
  use SiwappWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :meta_attributes, Plug.Conn)}
  end
<<<<<<< HEAD

  def render(assigns) do
    ~H"""
      <.form let={f} for={@meta_attributes} >
=======
  def render(assigns) do
    ~H"""
    <.form let={f} for={@meta_attributes} phx-change = "add-attribute">
>>>>>>> 676d2b263ea6d40f8f28e18cc41c38e5bc47f7df
      <%= live_component SiwappWeb.MetaAttributesLive.FormComponent, f: f %>
    </.form>
    """
  end
end

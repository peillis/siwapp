defmodule SiwappWeb.MetaAttributesLive do 
  use SiwappWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :meta_attributes, Plug.Conn)}
  end

  def render(assigns) do
    ~H"""
      <.form let={f} for={@meta_attributes} >
      <%= live_component SiwappWeb.MetaAttributesLive.FormComponent, f: f %>
    </.form>
    """
  end
end



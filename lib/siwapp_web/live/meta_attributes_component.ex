defmodule SiwappWeb.MetaAttributesComponent do
  use SiwappWeb, :live_component

  def render(%{meta_attributes: meta_attributes} = assigns) do
    ~H"""
    <fieldset>
    <%= for {k, v} <- meta_attributes do %>
      <input type="text" name="meta[keys][]" value={k} />
      <input type="text" name="meta[values][]" value={v} />
      <a phx-click="remove" phx-value-key={k} phx-target={@myself}>Remove</a>
      <br/>
    <% end %>
      <input type="text" name="meta[keys][]" />
      <input type="text" name="meta[values][]" />
      <br/>
    </fieldset>
    """
  end

  def handle_event("remove", %{"key" => key}, socket) do
    send self(), {:remove_meta, key}
    {:noreply, socket}
  end
end
